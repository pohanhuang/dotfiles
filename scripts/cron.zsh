# Install the dotfiles auto-sync job without changing unrelated crontab entries.

_dotfiles_install_cron() {
  emulate -L zsh
  set -euo pipefail

  local script_path repo_dir zsh_path git_path begin_marker end_marker current without_managed_block
  script_path="${(%):-%N}"
  repo_dir="${script_path:A:h:h}"
  zsh_path="${commands[zsh]:-zsh}"
  git_path="${commands[git]:-git}"
  begin_marker='# >>> dotfiles auto-sync >>>'
  end_marker='# <<< dotfiles auto-sync <<<'

  current="$(crontab -l 2>/dev/null || true)"
  without_managed_block="$(print -r -- "$current" | awk -v begin="$begin_marker" -v end="$end_marker" '
    $0 == begin { managed = 1; next }
    $0 == end { managed = 0; next }
    !managed { print }
  ')"

  {
    [[ -z "$without_managed_block" ]] || print -r -- "$without_managed_block"
    print -r -- "$begin_marker"
    print -r -- "0 */6 * * * ZDOTDIR=$repo_dir/zsh $zsh_path -c 'cd $repo_dir && $git_path pull && source scripts/src.zsh'"
    print -r -- "$end_marker"
  } | crontab -
}

_dotfiles_install_cron
unset -f _dotfiles_install_cron
