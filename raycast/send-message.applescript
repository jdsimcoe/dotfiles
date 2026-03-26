#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Text Colsey
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 💬
# @raycast.argument1 { "type": "text", "placeholder": "Recipient (phone or email)" }
# @raycast.argument2 { "type": "text", "placeholder": "Type message" }

# Documentation:
# @raycast.description Text Colsey
# @raycast.author Jonathan Simcoe
# @raycast.authorURL https://jdsimcoe.com

on run argv
  if (count of argv) is less than 2 then error "Expected recipient and message arguments"

  tell application "Messages"
    set targetBuddy to (item 1 of argv)
    set targetService to id of 1st account whose service type = iMessage
    set textMessage to (item 2 of argv)
    set theBuddy to participant targetBuddy of account id targetService
    send textMessage to theBuddy
  end tell
  log "Message sent"
end run
