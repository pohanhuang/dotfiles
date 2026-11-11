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

A modular zsh configuration with Starship, fzf, zoxide, and a small built-in plugin loader.

This Zsh configuration is based on and inspired by [radleylewis/zsh](https://github.com/radleylewis/zsh).
Thanks to Radley E. Sidwell-Lewis for building the great foundation it builds upon.

### Dependencies

#### Arch

```sh
paru -S zsh neovim eza bat fd fzf zoxide starship ripgrep
```

#### Ubuntu

```sh
sudo apt install zsh neovim eza bat fd-find fzf ripgrep
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -sS https://starship.rs/install.sh | sh
ln -s "$(command -v batcat)" ~/.local/bin/bat
ln -s "$(command -v fdfind)" ~/.local/bin/fd
```

#### macOS

```sh
# Run this first only when Homebrew is not already installed.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install zsh neovim eza bat fd fzf zoxide starship ripgrep
```

### Setup

```sh
ln -sfn ~/.config/dotfiles/zsh ~/.config/zsh
ln -sfn ~/.config/zsh/.zshenv ~/.zshenv
chsh -s "$(command -v zsh)"
exec zsh
```

`~/.zshenv` bootstraps `ZDOTDIR=~/.config/zsh`; no `/etc/zsh/zshenv` change is needed. The first interactive shell clones the configured plugins. Create `~/.config/zsh/local.zsh` for settings that belong only to the current machine.

### Configuration

| Path | Purpose |
|---|---|
| `zsh/.zshenv` | `ZDOTDIR`, XDG paths, editor, pager, and base `PATH` |
| `zsh/.zshrc` | History, completion, module loading, and startup order |
| `zsh/aliases.zsh` | General aliases and shell functions |
| `zsh/fzf.zsh` | fzf search and preview settings |
| `zsh/bindings.zsh` | zsh keybindings |
| `zsh/plugins.zsh` | Plugin download, loading, and update function |
| `zsh/prompt.zsh` / `zsh/starship.toml` | Starship prompt setup and appearance |
| `zsh/.zshrc.d/*.zsh` | Shared work helpers loaded by every machine |
| `zsh/local.zsh` | Machine-only overrides; ignored by Git and loaded last |

The shared helpers migrated from `.bashrc.d` are:

```text
agent.zsh             Sync Pi instructions and provide the Pi wrapper
go.zsh                Go module aliases
harvester.zsh         Harvester build helpers
herdr.zsh             Herdr shell helpers
neuvector-build.zsh   Neuvector image build helpers
neuvector-logs.zsh    Neuvector kubectl helpers
tmux.zsh              sesh and tmux helpers
```

Use the `.zsh` extension because these files are interpreted by zsh. The extension does not change how `source` works; it makes zsh-specific syntax obvious. Files are loaded alphabetically, so avoid dependencies between modules. Put a local override in `zsh/local.zsh`, which loads after all shared modules.

### Plugins

No third-party plugin manager is required. `zsh/plugins.zsh` clones missing plugins into `$ZDOTDIR/plugins/` on the first shell launch; that directory is ignored by Git. `git` and network access are required only for the first install and later updates.

| Plugin | Purpose |
|---|---|
| [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | Syntax highlighting |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-style inline suggestions |
| [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) | Up/down arrow history filtering |
| [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode) | Vi keybindings |

Update all installed plugins with:

```sh
zplugin-update
```

### Keybindings

| Key | Action |
|---|---|
| `Ctrl+R` | Fuzzy history search (fzf) |
| `Ctrl+F` | Fuzzy file search excluding hidden files (fzf + fd) |
| `Ctrl+→` | Move forward one word |
| `Ctrl+←` | Move backward one word |
| `↑` / `↓` | History search by prefix |
| `Ctrl+\` | Toggle autosuggestions |

Starship requires a [Nerd Font](https://www.nerdfonts.com) for the icons in `zsh/starship.toml`.

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
