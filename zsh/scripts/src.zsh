source "${ZDOTDIR:-$HOME}/.zshrc"
herdr server reload-config 2>/dev/null && echo "herdr config reloaded"

# re-link git global ignore from dotfiles
dotfiles_dir="${ZDOTDIR:A:h}"
mkdir -p "$HOME/.config/git"
ln -sfn "$dotfiles_dir/git/ignore" "$HOME/.config/git/ignore"
git config --global core.excludesFile "$HOME/.config/git/ignore"
