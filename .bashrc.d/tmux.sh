alias ta='tmux a \; choose-session'
tn() {
  tmux new ${1:+-s "$1"}
}
