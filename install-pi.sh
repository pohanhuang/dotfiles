#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target="$HOME/.pi/agent/extensions"
mkdir -p "$target"
ln -sfn "$root/pi/agent/extensions/plan-mode.ts" "$target/plan-mode.ts"
ln -sfn "$root/pi/agent/extensions/rtk.ts" "$target/rtk.ts"
ln -sfn "$root/pi/agent/extensions/pi-usage" "$target/pi-usage"

pi install https://github.com/ayghri/i-have-adhd
pi install npm:@dietrichgebert/ponytail
pi install npm:pi-web-access
