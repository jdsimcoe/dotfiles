setopt AUTO_CD

alias lg="lazygit"
alias ls="ls -Glaph"
alias ll="ls -Glaph -l"
alias la="ls -Glaph"
alias clean="$HOME/.local/bin/clean-dock.sh"
alias nightly="sudo /usr/local/bin/nightly-clean"
alias bt="$HOME/Developer/dotfiles/script/bt-reset"
alias bt-watch="$HOME/Developer/dotfiles/script/bt-watch"
alias bt-snapshot="$HOME/Developer/dotfiles/script/bt-snapshot"
alias h="history"
alias hg="history | tail -n 1000 | grep -i"
alias ..="cd .."
alias m="less"
alias dns-flush="sudo killall -HUP mDNSResponder"
alias reset-mail="sh $HOME/Developer/scripts/reset-mail.sh"
alias yarnclean="rm -rf node_modules/ package-lock.json && yarn"
alias src="source $HOME/.zshrc"
alias cursor='open -b com.todesktop.230313mzl4w4u92'

alias gd="git diff"
alias gs="git status 2>/dev/null"
alias ga="git add . && git add -u"
alias gp="git push"
alias gpr="gh pr create"

gc() {
  git add .
  git add -u
  git commit -m "$*"
}

gcp() {
  git add .
  git add -u
  git commit -m "$*"
  git push
}

gg() {
  git commit -m "$*"
}

gclone() {
  git clone "ssh://git@github.com/$1"
}

icon() {
  iconutil -c icns "$HOME/Desktop/$1.iconset"
}

iconstyle() {
  sudo chown -R jdsimcoe:staff /Applications/Slack.app
  sudo chmod -R 755 /Applications/Slack.app
  cp "$HOME/Documents/Icons/Slack.icns" /Applications/Slack.app/Contents/Resources/electron.icns

  sudo chown -R jdsimcoe:staff /Applications/Figma.app
  sudo chmod -R 755 /Applications/Figma.app
  cp "$HOME/Desktop/Figma.icns" /Applications/Figma.app/Contents/Resources/electron.icns

  rm -f /var/folders/*/*/*/com.apple.dock.iconcache 2>/dev/null
  sudo rm -rfv /Library/Caches/com.apple.iconservices.store 2>/dev/null
  sudo find /private/var/folders/ \( -name com.apple.dock.iconcache -o -name com.apple.iconservices\* \) -exec rm -rfv {} + 2>/dev/null

  sudo touch /Applications/* 2>/dev/null

  killall Dock
  killall Finder
}

webp() {
  if [[ $# -ne 1 ]]; then
    echo "usage: webp <directory>" >&2
    return 1
  fi

  local target_dir="$1"
  if [[ ! -d "$target_dir" ]]; then
    echo "webp: not a directory: $target_dir" >&2
    return 1
  fi

  if ! command -v cwebp >/dev/null 2>&1; then
    echo "webp: cwebp not found" >&2
    return 1
  fi

  local image extension output
  for image in "$target_dir"/*; do
    [[ -f "$image" ]] || continue

    extension="${image##*.}"
    extension="${extension:l}"
    case "$extension" in
      jpg|jpeg|png|tif|tiff|bmp)
        output="${image%.*}.webp"
        cwebp "$image" -o "$output"
        ;;
    esac
  done
}

remove-sentinel() {
  sudo launchctl remove com.sentinelone.sentineld-helper
  sudo launchctl remove com.sentinelone.sentineld-updater
  sudo launchctl remove com.sentinelone.sentineld
  sudo launchctl remove com.sentinelone.sentineld-guard

  sudo rm -rf /Library/Extensions/Sentinel.kext
  sudo rm -rf /Library/LaunchAgents/com.sentinelone.agent.plist
  sudo rm -rf /Library/LaunchDaemons/com.sentinelone.sentineld-guard.plist
  sudo rm -rf /Library/LaunchDaemons/com.sentinelone.sentineld-helper.plist
  sudo rm -rf /Library/LaunchDaemons/com.sentinelone.sentineld-updater.plist
  sudo rm -rf /Library/LaunchDaemons/com.sentinelone.sentineld.plist
  sudo rm -rf /Library/Preferences/Logging/Subsystems/com.sentinelone.sentinelctl.plist
  sudo rm -rf /Library/Preferences/Logging/Subsystems/com.sentinelone.sentineld-guard.plist
  sudo rm -rf /Library/Preferences/Logging/Subsystems/com.sentinelone.sentineld-helper.plist
  sudo rm -rf /Library/Preferences/Logging/Subsystems/com.sentinelone.sentineld-updater.plist
  sudo rm -rf /Library/Preferences/Logging/Subsystems/com.sentinelone.sentineld.plist
  sudo rm -rf /Library/Sentinel
  sudo rm -rf /private/etc/asl/com.sentinelone.sentinel
  sudo rm -rf /usr/local/share/man/man1/sentinelctl.1

  sudo pkgutil --forget com.sentinelone.pkg.sentinel-agent
}

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

# Added by Actual Computer installer
export PATH="$HOME/.actual/bin:$PATH"
