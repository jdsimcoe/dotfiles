#!/bin/zsh

# @raycast.schemaVersion 1
# @raycast.title Kill Zoom
# @raycast.mode silent
# @raycast.author Jonathan Simcoe
# @raycast.authorURL https://jdsimcoe.com
# @raycast.description Immediately force-kills Zoom without showing meeting confirmation dialogs.
# @raycast.packageName Kill Zoom

set -euo pipefail

if pkill -9 -f "[z]oom.us"; then
  printf 'Zoom killed\n'
else
  printf 'Zoom was not running\n'
fi
