#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Kill Zoom
# @raycast.mode silent
# @raycast.author Jonathan Simcoe
# @raycast.authorURL https:/jdsimcoe.com
# @raycast.description Kills Zoom by sending a HUP signal to the WindowServer process.
# @raycast.packageName Kill Zoom

pkill -f "zoom.us"
