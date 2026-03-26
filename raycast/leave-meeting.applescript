#!/usr/bin/osascript

# Required parameters:
# @raycast.author Jonathan Simcoe
# @raycast.authorURL https://github.com/jdsimcoe
# @raycast.schemaVersion 1
# @raycast.title Leave Meeting
# @raycast.mode silent
# @raycast.packageName Zoom
# @raycast.description Leaves Current Zoom meeting
# @raycast.needsConfirmation false


# Optional parameters:
# @raycast.icon images/zoom-logo.png


tell application "zoom.us"
	activate
	tell application "System Events"
		keystroke "w" using {command down}
		delay 0.5
		key code 36
		log "Meeting left"
	end tell
end tell
