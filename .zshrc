# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="hyperzsh"
POWERLINE_HIDE_USER_NAME="true"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git,jump,bower)

source $ZSH/oh-my-zsh.sh

# User configuration

ulimit -n 10000

export PATH="/usr/local/heroku/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local:/usr/local/php5/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin"
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

### Text editor shortcut
export EDITOR='atom'


### Go
export GOPATH=$HOME/Go
export PATH="$PATH:$GOPATH/bin"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# powerline
# . /usr/local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh

TERM="xterm-256color"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

### Some Aliases
alias start='sudo apachectl start'
alias stop='sudo apachectl stop'
alias restart='sudo apachectl restart'
alias back1='cd ..'
alias back2='cd ../..'
alias back3='cd ../../..'
alias back4='cd ../../../..'
alias cha='sudo chmod -R 777 .'
alias svd='svgo -f ~/Desktop'
alias io='imageOptim -d . -a'
alias iod='imageOptim -d ~/Desktop -a'
alias gphm='git push heroku master'
alias sub='git submodule update --init --recursive'
alias mail='mvim /var/mail/jdsimcoe'
alias sublp="~/Dropbox/Script/sublp.sh"
alias team="mvim ~/.teamocil"
alias things="sh ~/Dropbox/Script/things.sh"
alias hosts='atom /etc/hosts'
alias vhosts='atom /etc/apache2/extra/httpd-vhosts.conf'
alias git=hub
alias dep='npm run deploy'
alias ag='atom . && gulp'
alias npmsucks='rm -rf node_modules/ && npm install'
alias ls='ls -Glaph'
alias opalstaging='heroku run rails console -a opalstaging'
alias show-all='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hide-all='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
alias install-sketchtool='sh /Applications/Sketch.app/Contents/Resources/sketchtool/install.sh'
alias src="source ~/.zshrc"

# Jumps
function j() {
  jump "$@"
}

# Vim
function v() {
  mvim "$@"
}

# Teamocil
function t() {
  teamocil "$@"
}

# chmod a directory
function ch() {
  sudo chmod -R 777 "$@"
}

# chown a directory
function cho() {
  sudo chown -R www:www "$@"
}

# Do a Git clone
function gcl() {
  git clone "$@"
}

# Do a Git commit
function gc() {
  git add .;git add -u :/;git commit -m "$@";
}

# Do a Git push from the current branch
function gp() {
  git push origin "$@"
}

# Do a Git push setting the upstream from your current branch
function gpu() {
  git push --set-upstream origin "$@"
}

# Do a Git commit/push
function gcp() {
  git add .;git add -u :/;git commit -m "$@";git push
}

# Do a Git commit/push/deploy
function gcpd() {
  git add .;git add -u :/;git commit -m "$@";git push;sh utilities/deploy.sh
}

# Do a Git rebase
function gpr() {
  git pull --rebase "$@"
}

# Do a Git commit/push and a heroku deploy
function gcph() {
  git add .;git add -u :/;git commit -m "$@";git push;git push heroku master
}

# Do a Heroku commit/push/deploy
function gph() {
  git add .;git add -u :/;git commit -m "$@";git push heroku master
}

# Install a Gulp plugin and save to devDependencies
function gi() {
  npm install --save-dev gulp-"$@"
}

# Install a generic NPM module and save to devDependencies
function npmi() {
  npm install --save-dev "$@"
}

# svgo a directory
function sv() {
  svgo -f "$@"
}

# base64 image encoding
function base() {
  base64 -o ~/Desktop/base64.txt -i "$@"
  pbcopy < ~/Desktop/base64.txt
  rm -Rf ~/Desktop/base64.txt
}

# KillAll stuff
function ka() {
  killall "$@"
}

# WebKit2PNG security
function snap() {
  webkit2png -F -W 1440 -D ~/Snaps/ --ignore-ssl-check "$@" && open ~/Snaps
}

# Binary conversion
funcion txt2b() {
  echo "$@" | perl -lpe '$_=unpack"B*"'
}

function b2txt() {
  echo "$@" | perl -lpe '$_=pack"B*",$_'
}
