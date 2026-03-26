#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Close Zoom
# @raycast.mode silent

# Documentation:
# @raycast.description Close Zoom and Zoom-related tabs
# @raycast.author Jonathan Simcoe
# @raycast.authorURL https://jdsimcoe.com

on run argv
  tell application "Safari"
  	repeat with _window in windows
  		-- Work backwards through tabs to avoid index shifting issues
  		repeat with i from (count of tabs of _window) to 1 by -1
  			try
  				set _tab to tab i of _window
  				if URL of _tab contains "zoom.us" then
  					close _tab
  				end if
  			on error
  				-- Skip if tab no longer exists
  			end try
  		end repeat
  	end repeat
  end tell

  try
  	do shell script "pkill -f 'zoom.us'"
  on error
  	-- Silently ignore if no zoom processes found
  end try
end run
