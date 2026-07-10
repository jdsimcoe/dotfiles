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

bluelog() {
  sudo log show --predicate 'subsystem == "com.apple.bluetooth"' --last 30m > "$HOME/bt_drop.log"
}

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

macos-icon() {
  if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "usage: macos-icon <name[.icon]> [output-name[.icns]]" >&2
    return 1
  fi

  local icon_dir="${MACOS_ICON_DIR:-$HOME/Documents/Icons}"
  local input="$1"
  local source

  if [[ "$input" == */* ]]; then
    source="$input"
    [[ "$source" == "~/"* ]] && source="$HOME/${source#~/}"
  else
    source="$icon_dir/${input%.icon}.icon"
  fi

  if [[ ! -d "$source" ]]; then
    echo "macos-icon: source not found: $source" >&2
    return 1
  fi

  local base="${source:t}"
  base="${base%.icon}"

  local output_name="${2:-$base}"
  local output
  if [[ "$output_name" == */* ]]; then
    output="$output_name"
    [[ "$output" == "~/"* ]] && output="$HOME/${output#~/}"
  else
    output="$icon_dir/${output_name%.icns}.icns"
  fi

  local -a ictool_candidates=(
    "/Applications/Icon Composer.app/Contents/Executables/ictool"
    "/Applications/Xcode.app/Contents/Applications/Icon Composer.app/Contents/Executables/ictool"
    "/Applications/Xcode-beta.app/Contents/Applications/Icon Composer.app/Contents/Executables/ictool"
  )
  local ictool=""
  local candidate
  for candidate in "${ictool_candidates[@]}"; do
    if [[ -x "$candidate" ]]; then
      ictool="$candidate"
      break
    fi
  done

  if [[ -z "$ictool" ]]; then
    echo "macos-icon: Icon Composer ictool not found" >&2
    return 1
  fi

  if ! command -v iconutil >/dev/null 2>&1; then
    echo "macos-icon: iconutil not found" >&2
    return 1
  fi

  if ! command -v magick >/dev/null 2>&1; then
    echo "macos-icon: magick not found (install ImageMagick)" >&2
    return 1
  fi

  local fit_percent="${MACOS_ICON_FIT:-80.5}"
  if [[ ! "$fit_percent" =~ '^[0-9]+([.][0-9])?$' ]]; then
    echo "macos-icon: MACOS_ICON_FIT must be a number from 1 to 100" >&2
    return 1
  fi
  local fit_per_mille="${fit_percent/./}"
  if [[ "$fit_percent" != *.* ]]; then
    fit_per_mille="${fit_per_mille}0"
  fi
  if (( fit_per_mille < 10 || fit_per_mille > 1000 )); then
    echo "macos-icon: MACOS_ICON_FIT must be a number from 1 to 100" >&2
    return 1
  fi
  local shadow="${MACOS_ICON_SHADOW:-1}"
  local shadow_opacity="${MACOS_ICON_SHADOW_OPACITY:-18}"
  if [[ "$shadow" != 0 && "$shadow" != 1 ]]; then
    echo "macos-icon: MACOS_ICON_SHADOW must be 0 or 1" >&2
    return 1
  fi
  if [[ "$shadow_opacity" != <-> ]] || (( shadow_opacity < 0 || shadow_opacity > 100 )); then
    echo "macos-icon: MACOS_ICON_SHADOW_OPACITY must be a number from 0 to 100" >&2
    return 1
  fi
  local shadow_alpha
  if (( shadow_opacity == 100 )); then
    shadow_alpha=1
  else
    shadow_alpha="0.$(printf '%02d' "$shadow_opacity")"
  fi

  mkdir -p "${output:h}"

  local tmp_root
  tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/macos-icon.XXXXXX")" || return 1
  local iconset="$tmp_root/$base.iconset"
  local tmp_icns="$tmp_root/$base.icns"
  mkdir -p "$iconset"

  local -a icon_names=(
    icon_16x16.png
    icon_16x16@2x.png
    icon_32x32.png
    icon_32x32@2x.png
    icon_128x128.png
    icon_128x128@2x.png
    icon_256x256.png
    icon_256x256@2x.png
    icon_512x512.png
    icon_512x512@2x.png
  )
  local -a icon_widths=(16 16 32 32 128 128 256 256 512 512)
  local -a icon_scales=(1 2 1 2 1 2 1 2 1 2)

  local i
  for (( i = 1; i <= ${#icon_names[@]}; i++ )); do
    local render_width=$(( (icon_widths[$i] * fit_per_mille + 500) / 1000 ))
    local target_pixels=$(( icon_widths[$i] * icon_scales[$i] ))
    local raw_png="$tmp_root/raw-${icon_names[$i]}"
    local raw_icc="$tmp_root/raw-${icon_names[$i]}.icc"

    (( render_width > 0 )) || render_width=1

    "$ictool" "$source" \
      --export-image \
      --output-file "$raw_png" \
      --platform macOS \
      --rendition Default \
      --width "$render_width" \
      --height "$render_width" \
      --scale "${icon_scales[$i]}" >/dev/null || {
        rm -rf "$tmp_root"
        return 1
      }

    magick "$raw_png" "$raw_icc" || {
      rm -rf "$tmp_root"
      return 1
    }

    if (( shadow )); then
      local shadow_blur=$(( (target_pixels * 12 + 500) / 1000 ))
      local shadow_offset=$(( (target_pixels * 16 + 500) / 1000 ))
      local shadow_mask="$tmp_root/shadow-mask-${icon_names[$i]}"
      local shadow_png="$tmp_root/shadow-${icon_names[$i]}"
      (( shadow_blur > 0 )) || shadow_blur=1

      magick -size "${target_pixels}x${target_pixels}" xc:black \
        \( "$raw_png" -alpha extract \) \
        -gravity center -geometry "+0+${shadow_offset}" -compose lighten -composite \
        -blur "0x${shadow_blur}" -evaluate multiply "$shadow_alpha" \
        "$shadow_mask" || {
          rm -rf "$tmp_root"
          return 1
        }

      magick -size "${target_pixels}x${target_pixels}" xc:black \
        "$shadow_mask" \
        -alpha off \
        -compose CopyOpacity \
        -composite \
        "$shadow_png" || {
          rm -rf "$tmp_root"
          return 1
        }

      magick -size "${target_pixels}x${target_pixels}" xc:none \
        "$shadow_png" -compose over -composite \
        "$raw_png" -gravity center -geometry +0+0 -compose over -composite \
        +profile icc -profile "$raw_icc" \
        "$iconset/${icon_names[$i]}" || {
          rm -rf "$tmp_root"
          return 1
        }
    else
      magick "$raw_png" \
        -background none \
        -gravity center \
        -extent "${target_pixels}x${target_pixels}" \
        +profile icc -profile "$raw_icc" \
        "$iconset/${icon_names[$i]}" || {
          rm -rf "$tmp_root"
          return 1
        }
    fi
  done

  iconutil -c icns -o "$tmp_icns" "$iconset" || {
    rm -rf "$tmp_root"
    return 1
  }

  mv "$tmp_icns" "$output"
  rm -rf "$tmp_root"
  echo "wrote $output"
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
eval "$(/Users/jdsimcoe/.local/bin/mise activate zsh)"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
# <<< grok installer <<<

# User-local tools
export PATH="$HOME/.local/bin:$PATH"
