#!/usr/bin/env bash
# Reset Apple Mail UI/layout state (macOS)
# - Backs up relevant files first
# - Clears preferences, saved state, and caches
# - Does NOT delete your mail data in ~/Library/Mail
# - Restarts Mail when done

set -euo pipefail

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="${HOME}/Desktop/AppleMail-UI-Backup-${timestamp}"
mkdir -p "$backup_dir"

log() { printf "%s\n" "$*"; }

backup_and_remove() {
  local path="$1"
  if [ -e "$path" ]; then
    log "Backing up: $path"
    # Keep original structure under the backup folder
    rsync -a --relative "$path" "$backup_dir/" || true
    log "Removing:  $path"
    rm -rf "$path"
  else
    log "Not found (skipped): $path"
  fi
}

log "Quitting Mail…"
osascript -e 'tell application "Mail" to quit' >/dev/null 2>&1 || true
sleep 2
pkill -x Mail >/dev/null 2>&1 || true
pkill -x MailWebContent >/dev/null 2>&1 || true

log "Preparing backup folder: $backup_dir"

# Classic (non-sandbox container) locations still in use for prefs/UI
backup_and_remove "${HOME}/Library/Preferences/com.apple.mail.plist"
backup_and_remove "${HOME}/Library/Preferences/com.apple.mail-shared.plist"
backup_and_remove "${HOME}/Library/Saved Application State/com.apple.mail.savedState"
backup_and_remove "${HOME}/Library/Caches/com.apple.mail"

# Sandboxed container mirrors (varies by macOS version)
backup_and_remove "${HOME}/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail.plist"
backup_and_remove "${HOME}/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail-shared.plist"
backup_and_remove "${HOME}/Library/Containers/com.apple.mail/Data/Library/Saved Application State/com.apple.mail.savedState"
backup_and_remove "${HOME}/Library/Containers/com.apple.mail/Data/Library/Caches/com.apple.mail"

# Reset preferences daemon so Mail reads fresh prefs on next launch
log "Restarting preferences daemon…"
killall cfprefsd >/dev/null 2>&1 || true

log "Reopening Mail…"
open -a "Mail"

cat <<'NOTE'

Done.
What this reset touches:
- UI/layout preferences (toolbars, column layout, window positions)
- Saved window/application state
- Mail caches

What it does NOT touch:
- Your messages and mailboxes (~/Library/Mail/…)
- Internet Accounts (System Settings > Internet Accounts)

If the layout still looks odd after first launch:
- Quit Mail once more and open it again (first run can migrate settings).
- View > Customize Toolbar… and View > Use Column Layout (or message preview settings) as desired.

A full backup of removed items is on your Desktop:
  - AppleMail-UI-Backup-<timestamp>
You can restore any file by quitting Mail and copying it back to its original path.

NOTE
