#!/usr/bin/env zsh
set -euo pipefail

repo_dir="${0:A:h:h}"
config_dir="$HOME/.config/herdr"
plugin='bojackduy/nvim-herdr-navigation/herdr-vim-navigator'
plugin_ref='7798a2f027465698cb1a51695327e138319f61f3'

command -v herdr >/dev/null || {
  print -u2 'herdr is required; install it before running this script.'
  exit 1
}

if [[ -e "$config_dir" && ! -L "$config_dir" ]]; then
  print -u2 "$config_dir already exists; move it aside before running this script."
  exit 1
fi

mkdir -p "$HOME/.config"
ln -sfn "$repo_dir/herdr" "$config_dir"
herdr plugin install "$plugin" --ref "$plugin_ref" -y

command grep -qs '"local.vim-navigator"' "$config_dir/plugins.json" || {
  print -u2 'Herdr vim navigator plugin installation failed.'
  exit 1
}

print 'Herdr and local.vim-navigator are ready.'
