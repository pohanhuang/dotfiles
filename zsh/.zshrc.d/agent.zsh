# Keep the Pi agent instructions synced with this repository.
_dotfiles_dir="${${(%):-%N}:A:h:h:h}"
mkdir -p "$HOME/.pi/agent"
if [[ -f "$_dotfiles_dir/agents/AGENTS.md" ]] &&
  ! cmp -s "$_dotfiles_dir/agents/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"; then
  cp "$_dotfiles_dir/agents/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
fi
if [[ -f "$_dotfiles_dir/agents/keybindings.json" ]] &&
  ! cmp -s "$_dotfiles_dir/agents/keybindings.json" "$HOME/.pi/agent/keybindings.json"; then
  cp "$_dotfiles_dir/agents/keybindings.json" "$HOME/.pi/agent/keybindings.json"
fi
unset _dotfiles_dir

# Keep Pi current before running it.
pi() {
  command pi update --all
  command pi "$@"
}
