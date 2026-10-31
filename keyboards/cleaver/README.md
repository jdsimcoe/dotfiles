# Cleaver HE

Serene Industries Cleaver Hall Effect: QMK/VIA on an STM32F411, flashed over
USB DFU (no drive appears). Firmware source and releases live in
[serene-industries/firmware](https://github.com/serene-industries/firmware)
(`boards/wired/cleaver/`, tags `cleaver-he-v<version>`).

- `keymap.json` is a backup exported from the SI Keyboard Configurator.
  Re-import it there if a flash resets the keymap.

## Flashing

1. Put the board in bootloader mode: hold the key right of ↑ and press Esc.
   It enumerates as `STM32 BOOTLOADER (0483:DF11)`.
2. Run:

   ```bash
   ./script/flash-cleaver            # latest release, macOS layout
   ./script/flash-cleaver via        # latest release, Windows layout
   ./script/flash-cleaver mac 0.4.2.7
   ```

   It downloads the release `.bin` with `gh`, writes it with Homebrew's
   `dfu-util` (installed by `brew.sh`), reads the flash back to confirm it
   matches, and reboots the board. To exit bootloader without flashing, unplug
   and replug.

QMK Toolbox works too, but 0.3.4 bundles an Intel-only `dfu-util` that fails
with "Bad CPU type in executable" on Apple Silicon unless Rosetta is installed.

## Firmware version shown in the configurator

The configurator showed "FW v0.0.0.41" with "update v0.4.2.7 available" even
after a successful 0.4.2.7 flash. The firmware doesn't embed its release
version: `keyboard.json` keeps `device_version` at `0.0.1` (USB `bcdDevice`
`0x0001`) across releases, so the configurator can't tell builds apart. Trust
the read-back check in `flash-cleaver`, or the changelog's behavior changes,
over that label.
