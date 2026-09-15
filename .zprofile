# Homebrew lives in /opt/homebrew on Apple Silicon and /usr/local on Intel.
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [[ -x "$brew_bin" ]]; then
    eval "$("$brew_bin" shellenv zsh)"
    break
  fi
done
unset brew_bin

if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  export CPATH="$HOMEBREW_PREFIX/include"
  export LIBRARY_PATH="$HOMEBREW_PREFIX/lib"
fi

export PATH="$HOME/.local/bin:$PATH"
export TERM="xterm-256color"

ulimit -n 10000
