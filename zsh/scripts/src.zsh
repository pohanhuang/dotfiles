source "${ZDOTDIR:-$HOME}/.zshrc"
herdr server reload-config 2>/dev/null && echo "herdr config reloaded"
