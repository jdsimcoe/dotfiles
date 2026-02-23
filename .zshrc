# ZSH
ls --version &>/dev/null
if [ $? -eq 0 ]; then
  lsflags="--color --group-directories-first -F"
else
  lsflags="-Glaph"
  export CLICOLOR=1
fi
alias ls="ls ${lsflags}"
alias ll="ls ${lsflags} -l"
alias la="ls ${lsflags} -la"
alias clean="~/.local/bin/clean-dock.sh"
alias bt="sudo pkill bluetoothd"
alias h="history"
alias hg="history -1000 | grep -i"
alias ,="cd .."
alias m="less"
alias dns-flush='sudo killall -HUP mDNSResponder'
alias reset-mail='sh ~/Developer/scripts/reset-mail.sh'
alias yarnclean='rm -rf node_modules/ && rm -rf package-lock.json && yarn'
alias src='source ~/.zshrc'
autoload -Uz compinit && compinit
setopt complete_in_word         # cd /ho/sco/tm<TAB> expands to /home/scott/tmp
setopt auto_menu                # show completion menu on succesive tab presses
setopt autocd                   # cd to a folder just by typing it's name
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&' # These "eat" the auto prior space after a tab complete

# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/bin:$PATH"
export CPATH="/opt/homebrew/include"
export LIBRARY_PATH="/opt/homebrew/lib"

# Zed
#export EDITOR="zed --wait"

# Cursor
alias cursor='open -b com.todesktop.230313mzl4w4u92 "$@"'

# Claude Code
# Set in ~/.zshrc.local (untracked)

# GIT
alias gd="git diff"
alias gs="git status 2>/dev/null"
alias ga='git add .; git add -u'
alias gp='git push'
alias gpr='gh pr create'
function gc() { git clone ssh://git@github.com/"$*" }
function gg() { git commit -m "$*" }
function gc() {
  git add .;
  git add -u;
  git commit -m $@;
}
function gcp() {
  git add .;
  git add -u;
  git commit -m $@;
  git push;
}

# Icon generator
function icon() {
 iconutil -c icns ~/Desktop/"$@".iconset
}

function iconstyle() {
  # Reset Slack icon
  sudo chown -R jdsimcoe:staff /Applications/Slack.app
  sudo chmod -R 755 /Applications/Slack.app
  cp ~/Documents/Icons/Slack.icns /Applications/Slack.app/Contents/Resources/electron.icns

  # Reset Figma icon
  sudo chown -R jdsimcoe:staff /Applications/Figma.app
  sudo chmod -R 755 /Applications/Figma.app
  cp ~/Desktop/Figma.icns /Applications/Figma.app/Contents/Resources/electron.icns

  # Clean system icon cache (safely)
  rm -f /var/folders/*/*/*/com.apple.dock.iconcache 2>/dev/null
  sudo rm -rfv /Library/Caches/com.apple.iconservices.store 2>/dev/null
  sudo find /private/var/folders/ \( -name com.apple.dock.iconcache -or -name com.apple.iconservices* \) -exec rm -rfv {} + 2>/dev/null

  # Refresh all app icon metadata (may show errors for SIP-protected apps)
  sudo touch /Applications/* 2>/dev/null

  # Restart dock & finder
  killall Dock
  killall Finder
}

function remove-sentinel() {
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

# Direnv
eval "$(direnv hook zsh)"

# Starship prompt
eval "$(starship init zsh)"

# Vercel AI Gateway
# Set in ~/.zshrc.local (untracked)
export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Local machine-only secrets and overrides
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
