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

After the first 0.4.2.7 flash (via `dfu-util`'s `:leave`), the configurator
kept showing "FW v0.0.0.41" with "update v0.4.2.7 available". After a second
flash with `flash-cleaver` it showed the new version. The configurator doesn't
read the version from USB (`bcdDevice` stays `0x0001` on every release), so
it's unclear which step fixed the label. If it looks stale, trust the
read-back check in `flash-cleaver` over the label.
