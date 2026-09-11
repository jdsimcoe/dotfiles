### dotfiles

Personal machine setup split into:

- `brew.sh` for Homebrew taps/formulae/casks
- `.macos` for macOS system defaults/preferences
- separate config files/directories (`.hushlogin`, `.zprofile`, `.zshrc`, `.config/starship.toml`, `.config/nvim`, `.config/ghostty/config`, `.config/karabiner/*`, `.config/zed/settings.json`)
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
- symlink repo files into place (`.hushlogin`, `.zprofile`, `.zshrc`, Starship, Neovim, Ghostty, Karabiner, Zed settings)
- set global Git defaults like `push.autoSetupRemote=true`, `user.email`, and `user.name`
- switch your login shell to zsh
- run `brew.sh` (unless you pass `--skip-brew`)
- install cliamp settings and visualizers, with ANSIgray and ANSIbrot as defaults
- run `.macos` (unless you pass `--skip-macos`)

Example:

```bash
./script/setup --skip-macos
```

Validate that your managed files are still symlinked back to the repo:

```bash
./script/doctor
```

#### cliamp: ANSIgray + ANSIbrot

New-machine `script/setup` installs cliamp through its Homebrew tap, along with
Python, ffmpeg, and yt-dlp, then restores the saved cliamp configuration and
all seven visualizer plugins. To install or refresh only cliamp:

```bash
./script/setup-cliamp
source ~/.zshrc
amp
```

The saved settings include +6 dB volume, YouTube Music as the default provider,
Safari as the cookie source, playlist expansion, Tidal lossless, flat EQ,
automatic sample rate, 32-bit output, `~/Music`, shuffle off, and 1× speed.
Existing machine-specific settings are preserved; missing settings are filled
from `.config/cliamp/config.toml`. The installer sets ANSIgray and ANSIbrot as
the defaults and backs up changed files before installing them.

- **ANSIgray** reads the terminal's foreground/background and neutral ANSI slots
  0, 7, 8, and 15 at every `amp` launch. It resolves them to the hex values
  required by cliamp and chooses neutral accents for dark or light backgrounds.
- **ANSIbrot** renders directly with the terminal's normal and bright ANSI
  color slots 1–6 and 9–14. Its colors follow any terminal palette, including
  bright pink, yellow, and green where the terminal defines them.

The original Mandelbrot, led-burst, Nightrider, Nova, tubeamp, and vu-meter
plugins are also saved. All seven plugins are linked to the repo and trusted
by the installer. Re-run setup-cliamp after editing them, then relaunch the
player so cliamp loads the updated Lua code.

While cliamp is running, switch ANSIbrot from a second terminal tab:

```bash
cliamp plugins call ANSIbrot palette ansi
cliamp plugins call ANSIbrot palette grayscale
```

The visualizer defaults to full ANSI color; its palette choice persists.
The interface remains grayscale. "Grayscale" uses the terminal's neutral
slots, preserving any tint assigned by the terminal theme.

The launcher requires OSC 4, 10, and 11 color-query support. If queries are
unavailable, it uses the last resolved ANSIgray theme or a neutral first-run
fallback. Plain `cliamp` uses cached colors; use `amp` to refresh them.
`CLIAMP_CONFIG_DIR` and `XDG_CONFIG_HOME` are honored.

Runtime config and generated colors are kept outside the repo. Authentication
tokens, browser cookies, history, resume state, logs, and sockets stay local;
sign in to Tidal and Safari again on a new machine. There are currently no
saved local playlists or favorites to restore. Edit the saved config template
to change defaults for future installs.

#### Local secrets

Keep machine-only zsh overrides in `~/.zshrc.local`.
See [`.zshrc.local.example`](/Users/jdsimcoe/Developer/dotfiles/.zshrc.local.example) for placeholders.

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
