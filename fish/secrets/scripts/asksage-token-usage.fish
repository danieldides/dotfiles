#!/usr/bin/env fish

set -l script_dir (dirname (status filename))
set -l token_file "$script_dir/token.txt"

if not test -r "$token_file"
    echo "AskSage token file is not readable: $token_file" >&2
    exit 1
end

set -l token (string trim < "$token_file")

curl --fail --silent --show-error \
    --header "x-access-tokens: $token" \
    https://api.asksage.ai/server/count-monthly-tokens | \
    python3 -c '
import json
import sys

payload = json.load(sys.stdin)
if payload.get("status") != 200:
    raise SystemExit("AskSage API error: {}".format(payload.get("response", "unknown error")))
print("AskSage inference tokens used this month: {:,}".format(payload["response"]))
'
