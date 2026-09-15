{
  "content": "if [[ -x /opt/homebrew/bin/brew ]]; then\n  eval \"$(/opt/homebrew/bin/brew shellenv zsh)\"\nfi\n\nexport PATH=\"/opt/homebrew/bin:$HOME/.local/bin:$PATH\"\nexport CPATH=\"/opt/homebrew/include\"\nexport LIBRARY_PATH=\"/opt/homebrew/lib\"\nexport NVM_DIR=\"$HOME/.nvm\"\nexport TERM=\"xterm-256color\"\n\nulimit -n 10000\n\nif [[ -s \"$NVM_DIR/nvm.sh\" ]]; then\n  . \"$NVM_DIR/nvm.sh\"\nfi\n\nif [[ -s \"$NVM_DIR/bash_completion\" ]]; then\n  . \"$NVM_DIR/bash_completion\"\nfi\n",
  "name": "cloud_browser_execute_js"
}
