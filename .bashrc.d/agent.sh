pi install ~/.config/dotfiles/pi-skills
cp ~/.config/dotfiles/agents/AGENTS.md ~/.pi/agent/AGENTS.md

# ==== ensure pi is latestet ====
pi() {
  command pi update --all
  command pi "$@"
}
