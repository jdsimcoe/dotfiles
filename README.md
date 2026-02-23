### dotfiles

Personal machine setup split into:

- `brew.sh` for Homebrew taps/formulae/casks
- `.macos` for macOS system defaults/preferences
- separate config files/directories (`.zshrc`, `.config/nvim`, `.config/ghostty/config`, `.config/karabiner/*`, `.config/zed/settings.json`)
- `script/setup` as the master bootstrap script for new machines
- `script/clean` as an optional manual maintenance/cleanup script (not run by setup)

#### New machine setup

```bash
cd ~/Developer/dotfiles
chmod +x script/setup
./script/setup
```

This will:

- back up existing files into `~/.dotfiles-backups/<timestamp>/`
- symlink repo files into place (`.zshrc`, Neovim, Ghostty, Karabiner, Zed settings)
- run `brew.sh` (unless you pass `--skip-brew`)
- run `.macos` (unless you pass `--skip-macos`)

Example:

```bash
./script/setup --skip-macos
```

#### Local secrets

Keep machine-only secrets out of the repo in `~/.zshrc.local`.

See `.zshrc.local.example` for placeholders.

#### Optional maintenance

Run the cleanup script manually when needed:

```bash
./script/clean
```
