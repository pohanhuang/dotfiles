#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target="$HOME/.pi/agent/extensions"
mkdir -p "$target"
ln -sfn "$root/pi/agent/extensions/plan-mode.ts" "$target/plan-mode.ts"
ln -sfn "$root/pi/agent/extensions/rtk.ts" "$target/rtk.ts"
ln -sfn "$root/pi/agent/extensions/pi-usage" "$target/pi-usage"

# link local skills into pi's git package directory
mkdir -p "$HOME/.pi/agent/git/local"
ln -sfn "$root/pi-skills" "$HOME/.pi/agent/git/local/pi-skills"

pi install https://github.com/ayghri/i-have-adhd
pi install npm:@dietrichgebert/ponytail
pi install npm:pi-web-access
