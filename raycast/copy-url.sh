#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Copy URL
# @raycast.mode silent
# @raycast.author Jonathan Simcoe
# @raycast.authorURL https://jdsimcoe.com
# @raycast.description Copy the current Safari tab URL without common tracking parameters
# @raycast.packageName Safari

set -euo pipefail

url="$(
  osascript <<'APPLESCRIPT'
tell application "Safari"
  if (count of windows) is 0 then
    error "Safari has no open windows."
  end if

  set currentTab to current tab of front window
  return URL of currentTab
end tell
APPLESCRIPT
)"

clean_url="$(
  CURRENT_URL="$url" python3 <<'PYTHON'
import os
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

url = os.environ["CURRENT_URL"].strip()
parts = urlsplit(url)

tracking_keys = {
    "fbclid",
    "gclid",
    "gclsrc",
    "dclid",
    "msclkid",
    "ttclid",
    "twclid",
    "yclid",
    "ysclid",
    "_hsenc",
    "_hsmi",
    "hsctatracking",
    "mc_cid",
    "mc_eid",
    "mkt_tok",
    "oly_anon_id",
    "oly_enc_id",
    "rb_clickid",
    "s_cid",
    "wickedid",
}

filtered_query = []
for key, value in parse_qsl(parts.query, keep_blank_values=True):
    normalized_key = key.lower()
    if normalized_key.startswith("utm_"):
        continue
    if normalized_key in tracking_keys:
        continue
    filtered_query.append((key, value))

cleaned = urlunsplit(
    (
        parts.scheme.lower(),
        parts.netloc.lower(),
        parts.path or "",
        urlencode(filtered_query, doseq=True),
        parts.fragment,
    )
)

print(cleaned)
PYTHON
)"

printf '%s' "$clean_url" | pbcopy
printf 'Clean URL copied\n'
