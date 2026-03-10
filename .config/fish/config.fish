# Homebrew environment
if test -x /opt/homebrew/bin/brew
    eval "$(/opt/homebrew/bin/brew shellenv)"
end

fish_add_path --move --path /opt/homebrew/bin
fish_add_path --move --path $HOME/.local/bin

set -gx CPATH /opt/homebrew/include
set -gx LIBRARY_PATH /opt/homebrew/lib

# Interactive shell behavior
if status is-interactive
    set -g fish_greeting
end

# ls flags are platform-dependent
if ls --version >/dev/null 2>&1
    set -g lsflags --color --group-directories-first -F
else
    set -g lsflags -Glaph
    set -gx CLICOLOR 1
end

# Core aliases
alias lg "lazygit"
alias ls "ls $lsflags"
alias ll "ls $lsflags -l"
alias la "ls $lsflags -la"
alias clean "~/.local/bin/clean-dock.sh"
alias nightly "sudo /usr/local/bin/nightly-clean"
alias bt "~/Developer/dotfiles/script/bt-reset"
alias bt-watch "~/Developer/dotfiles/script/bt-watch"
alias bt-snapshot "~/Developer/dotfiles/script/bt-snapshot"
alias h "history"
alias hg "history | tail -n 1000 | grep -i"
alias .. "cd .."
alias m "less"
alias dns-flush "sudo killall -HUP mDNSResponder"
alias reset-mail "sh ~/Developer/scripts/reset-mail.sh"
alias yarnclean "rm -rf node_modules/; rm -rf package-lock.json; yarn"
alias src "source ~/.config/fish/config.fish"
alias cursor 'open -b com.todesktop.230313mzl4w4u92'

# Git helpers
alias gd "git diff"
alias gs "git status 2>/dev/null"
alias ga "git add .; git add -u"
alias gp "git push"
alias gpr "gh pr create"

function gc
    git add .
    git add -u
    git commit -m "$argv"
end

function gcp
    git add .
    git add -u
    git commit -m "$argv"
    git push
end

function gg
    git commit -m "$argv"
end

function gclone
    git clone "ssh://git@github.com/$argv"
end

function icon
    iconutil -c icns ~/Desktop/"$argv".iconset
end

function iconstyle
    sudo chown -R jdsimcoe:staff /Applications/Slack.app
    sudo chmod -R 755 /Applications/Slack.app
    cp ~/Documents/Icons/Slack.icns /Applications/Slack.app/Contents/Resources/electron.icns

    sudo chown -R jdsimcoe:staff /Applications/Figma.app
    sudo chmod -R 755 /Applications/Figma.app
    cp ~/Desktop/Figma.icns /Applications/Figma.app/Contents/Resources/electron.icns

    rm -f /var/folders/*/*/*/com.apple.dock.iconcache 2>/dev/null
    sudo rm -rfv /Library/Caches/com.apple.iconservices.store 2>/dev/null
    sudo find /private/var/folders/ \( -name com.apple.dock.iconcache -o -name com.apple.iconservices\* \) -exec rm -rfv {} + 2>/dev/null

    sudo touch /Applications/* 2>/dev/null

    killall Dock
    killall Finder
end

function webp
    if test (count $argv) -ne 1
        echo "usage: webp <directory>" >&2
        return 1
    end

    set -l target_dir $argv[1]
    if not test -d "$target_dir"
        echo "webp: not a directory: $target_dir" >&2
        return 1
    end

    if not command -q cwebp
        echo "webp: cwebp not found" >&2
        return 1
    end

    for image in "$target_dir"/*
        if not test -f "$image"
            continue
        end

        set -l extension (string lower -- (path extension "$image"))
        switch "$extension"
            case .jpg .jpeg .png .tif .tiff .bmp
                set -l output (path change-extension webp "$image")
                cwebp "$image" -o "$output"
        end
    end
end

function remove-sentinel
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
end

# Tooling hooks
if command -q direnv
    direnv hook fish | source
end

if command -q starship
    starship init fish | source
end

# Local machine-only secrets and overrides
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
