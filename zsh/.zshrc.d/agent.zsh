# Keep the Pi agent instructions synced with this repository.
_dotfiles_dir="${${(%):-%N}:A:h:h:h}"
if [[ -f "$_dotfiles_dir/agents/AGENTS.md" ]] &&
  ! cmp -s "$_dotfiles_dir/agents/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"; then
  mkdir -p "$HOME/.pi/agent"
  cp "$_dotfiles_dir/agents/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
fi
unset _dotfiles_dir

# Keep Pi current before running it.
pi() {
  command pi update --all
  command pi "$@"
}
