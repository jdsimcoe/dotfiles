### dotfiles

Personal machine setup split into:

- `brew.sh` for Homebrew taps/formulae/casks
- `.macos` for macOS system defaults/preferences
- separate config files/directories (`.hushlogin`, `.zprofile`, `.zshrc`, `.config/starship.toml`, `.config/nvim`, `.config/ghostty/*`, `.config/karabiner/*`, `.config/zed/settings.json`)
- `fonts/pragma` with the Pragma terminal font (custom Iosevka build) installed by setup
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
- symlink repo files into place (`.hushlogin`, `.zprofile`, `.zshrc`, Starship, Neovim, Ghostty config and themes, Karabiner, Zed settings)
- copy the Pragma font into `~/Library/Fonts/`
- set global Git defaults like `push.autoSetupRemote=true`, `user.email`, and `user.name`
- switch your login shell to zsh
- run `brew.sh` (unless you pass `--skip-brew`), which also installs Node.js LTS through fnm
- install cliamp settings and visualizers, with ANSIgray and ANSIbrot as defaults
- run `.macos` (unless you pass `--skip-macos`), including setting Mail's message list and message fonts to System 12

Example:

```bash
./script/setup --skip-macos
```

Validate that your managed files are still symlinked back to the repo:

```bash
./script/doctor
```

#### Ghostty terminal

The Ghostty config is symlinked to `~/Library/Application Support/com.mitchellh.ghostty/config`
and custom color themes (Atom Zed Dark, Atelier Forest Dark/Light) to
`~/.config/ghostty/themes/`, where Ghostty resolves the config's `theme =`
value. The terminal font is Pragma, a custom Iosevka build tracked in
[`fonts/pragma`](fonts/pragma) and copied into `~/Library/Fonts/` by setup, so
font and colors carry over to a new machine without manual steps. Restart
Ghostty (or reload the config) after setup to pick everything up.

#### Node.js

Node is managed by [fnm](https://github.com/Schniz/fnm), not the Homebrew
`node` formula: Homebrew no longer bottles node for Intel macOS, so on Intel
Macs `brew install node` compiles from source for hours. fnm downloads
official prebuilt nodejs.org binaries for both architectures. `brew.sh`
installs fnm, the current LTS, enables corepack (bundled with Node), and
installs `vercel` through npm. `.zshrc` activates fnm with `--use-on-cd`, so
directories with a `.node-version` or `.nvmrc` switch versions automatically.

```bash
fnm install 24        # install another version
fnm default 24        # make it the default
fnm list              # what's installed
```

Older machines that still have the Homebrew `node`, `corepack`, or
`vercel-cli` formulae can drop them with:

```bash
brew uninstall --ignore-dependencies vercel-cli corepack node
```

#### Mail system font

The macOS setup applies **System Font Regular 12** to Mail's message list and messages. It generates the archived AppKit font on the current Mac rather than storing an OS-specific binary value in the repo.

To reapply it independently or choose another integer size:

```bash
./script/set-mail-system-font 12
```

Run it from a terminal app with Full Disk Access, then relaunch that terminal app before executing the script. No `sudo` is required.

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

`amp` also filters emoji from YouTube titles returned by yt-dlp. It removes
emoji sequences and tidies leftover whitespace while preserving letters,
accents, numbers, and ordinary punctuation. This affects cliamp's imported
titles; it does not edit YouTube or change standalone yt-dlp commands. Relaunch
`amp` and reopen the playlist to refresh titles already held in memory. This
filter covers the configured browser-cookie YouTube providers; titles loaded
from saved playlists or the separate Google OAuth provider are not filtered.

Runtime config and generated colors are kept outside the repo. Authentication
tokens, browser cookies, history, resume state, logs, and sockets stay local;
sign in to Tidal and Safari again on a new machine. There are currently no
saved local playlists or favorites to restore. Edit the saved config template
to change defaults for future installs.

#### Local secrets

Keep machine-only zsh overrides in `~/.zshrc.local`.
See [`.zshrc.local.example`](/Users/jdsimcoe/Developer/dotfiles/.zshrc.local.example) for placeholders.

#### Optional maintenance

Run the prompted cleanup script manually when needed:

```bash
./script/clean
```

For aggressive unattended maintenance every Friday at 23:59, install the
system LaunchDaemon once:

```bash
./script/setup-nightly-clean
```

The Mac wakes at 23:57, runs Mole cleanup/optimization, purges package-manager
and Xcode caches, removes old diagnostics and local APFS snapshots, and rotates
its logs. It restarts afterward only when the console has been idle for at
least 30 minutes. It does not install macOS updates.

Preview the unattended job without deleting anything or restarting:

```bash
sudo /usr/local/bin/nightly-clean --dry-run
```

Logs are stored in `/Library/Logs/com.jdsimcoe.nightly-clean/` for 60 days.

Bluetooth helpers:

```bash
./script/bt-reset
./script/bt-watch 120
./script/bt-snapshot
```

- `bt-reset` cycles Bluetooth power with `blueutil` installed by `brew.sh`, otherwise restarts `bluetoothd`
- `bt-watch` streams `bluetoothd` and sleep/wake-related logs for a short window
- `bt-snapshot` saves a support bundle with Bluetooth state, recent `bluetoothd` logs, and recent sleep/wake history

#### Fix app ownership

Re-take ownership of apps that iru (endpoint management) chowns back to root, which blocks [Pictogram](https://pictogramapp.com) from applying custom icons. Prompts for sudo, then runs `chown -R $USER:staff` and `chmod -R u+rwX` on each app.

```bash
chmod +x script/chowny

# Fix the default list (Claude.app)
./script/chowny

# Or fix specific apps
./script/chowny "/Applications/Claude.app" "/Applications/Slack.app"
```

Edit the `default_apps` array at the top of the script to change the defaults. iru re-chowns apps on its next sweep, so re-run after each reset, then re-apply the icon in Pictogram.
