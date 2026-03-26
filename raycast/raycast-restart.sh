#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Restart Raycast
# @raycast.mode silent
# @raycast.author Jonathan Simcoe
# @raycast.authorURL https:/jdsimcoe.com
# @raycast.description Restarts Raycast by sending a HUP signal to the WindowServer process.
# @raycast.packageName Restart Raycast

pkill -f "Raycast"
open -a "Raycast"
