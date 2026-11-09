#!/usr/bin/env bash

# Ensure the herdr vim-navigator plugin (ctrl+hjkl across nvim splits and
# herdr panes) is installed. plugins.json is machine-local and gitignored,
# so a fresh machine installs it on the first shell; afterwards this is a grep.
HERDR_VIM_NAVIGATOR_SRC="bojackduy/nvim-herdr-navigation/herdr-vim-navigator"
HERDR_VIM_NAVIGATOR_REF="7798a2f027465698cb1a51695327e138319f61f3"

if command -v herdr >/dev/null 2>&1 &&
  ! grep -qs '"local.vim-navigator"' ~/.config/herdr/plugins.json; then
  herdr plugin install --ref "$HERDR_VIM_NAVIGATOR_REF" -y "$HERDR_VIM_NAVIGATOR_SRC" >/dev/null 2>&1
fi
