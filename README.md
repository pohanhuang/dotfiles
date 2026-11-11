# Dotfiles

## Installation

```sh
mkdir -p ~/.config
git clone git@github.com:pohanhuang/dotfiles.git ~/.config/dotfiles

# macOS: install Homebrew first when brew is not available
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install neovim lazygit
curl -fsSL https://herdr.dev/install.sh | sh

ln -sfn ~/.config/dotfiles/nvim ~/.config/nvim
ln -sfn ~/.config/dotfiles/lazygit ~/.config/lazygit
zsh ~/.config/dotfiles/scripts/setup-herdr.zsh
```

## zsh setup

Install zsh and the tools you use. The full dependency list is in [zsh/README.md](zsh/README.md). The zsh configuration is based on [radleylewis/zsh](https://github.com/radleylewis/zsh).

```sh
ln -sfn ~/.config/dotfiles/zsh ~/.config/zsh
ln -sfn ~/.config/zsh/.zshenv ~/.zshenv
chsh -s "$(command -v zsh)"
exec zsh
```

The first zsh launch installs the configured plugins. Shared work helpers are in `zsh/.zshrc.d/*.zsh`; use the ignored `zsh/local.zsh` for machine-only paths, credentials, or overrides.

## Pi setup

```sh
zsh ~/.config/dotfiles/scripts/setup-pi.zsh

pi install npm:@po.dev/pi-usage-dashboard
pi install npm:@po.dev/pi-branch-workspace
pi install npm:@po.dev/pi-ask-me
pi install npm:@po.dev/pi-file-ref-links
pi install npm:pi-claude-bridge
```

The setup script installs the local Pi skills and copies `agents/AGENTS.md` to `~/.pi/agent/AGENTS.md`. Each zsh startup then updates that copy only when the repository version changes. The setup script requires `pi` to be installed first.

Private Pi sessions, credentials, and `~/.pi/agent/usage/events.jsonl` are intentionally not tracked.

## herdr setup (new machine)

Install Herdr first, then run the setup script. It refuses to overwrite an existing `~/.config/herdr` directory, so back it up first when needed.

```sh
curl -fsSL https://herdr.dev/install.sh | sh

if [ -e ~/.config/herdr ] && [ ! -L ~/.config/herdr ]; then
  mv ~/.config/herdr ~/.config/herdr.backup-"$(date +%Y%m%d-%H%M%S)"
fi

zsh ~/.config/dotfiles/scripts/setup-herdr.zsh
readlink ~/.config/herdr # ~/.config/dotfiles/herdr

# ha/hd need all three dependencies
command -v fzf zoxide python3
exec zsh && type hd && hd .
```

The setup script symlinks the repository's Herdr config, installs `local.vim-navigator`, and verifies its plugin action is available. To restore a backup, remove the symlink and rename the chosen `~/.config/herdr.backup-*` directory to `~/.config/herdr`.
