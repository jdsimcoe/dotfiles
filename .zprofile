if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
export CPATH="/opt/homebrew/include"
export LIBRARY_PATH="/opt/homebrew/lib"
export NVM_DIR="$HOME/.nvm"
export TERM="xterm-256color"

ulimit -n 10000

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  . "$NVM_DIR/nvm.sh"
fi

if [[ -s "$NVM_DIR/bash_completion" ]]; then
  . "$NVM_DIR/bash_completion"
fi
