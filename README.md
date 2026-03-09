### dotfiles

Personal machine setup split into:

- `brew.sh` for Homebrew taps/formulae/casks
- `.macos` for macOS system defaults/preferences
- separate config files/directories (`.hushlogin`, `.zshrc`, `.config/starship.toml`, `.config/nvim`, `.config/ghostty/config`, `.config/karabiner/*`, `.config/zed/settings.json`)
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
- symlink repo files into place (`.hushlogin`, `.zshrc`, Starship, Neovim, Ghostty, Karabiner, Zed settings)
- run `brew.sh` (unless you pass `--skip-brew`)
- run `.macos` (unless you pass `--skip-macos`)

Example:

```bash
./script/setup --skip-macos
```

Validate that your managed files are still symlinked back to the repo:

```bash
./script/doctor
```

#### Local secrets

Keep machine-only secrets out of the repo in `~/.zshrc.local`.

See `.zshrc.local.example` for placeholders.

#### Optional maintenance

Run the cleanup script manually when needed:

```bash
./script/clean
```

Bluetooth helpers:

```bash
./script/bt-reset
./script/bt-watch 120
./script/bt-snapshot
```

- `bt-reset` cycles Bluetooth power with `blueutil` installed by `brew.sh`, otherwise restarts `bluetoothd`
- `bt-watch` streams `bluetoothd` and sleep/wake-related logs for a short window
- `bt-snapshot` saves a support bundle with Bluetooth state, recent `bluetoothd` logs, and recent sleep/wake history
