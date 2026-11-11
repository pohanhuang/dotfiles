# zsh

A modular zsh configuration with Starship, fzf, zoxide, and a small built-in plugin loader.

## Dependencies

### Arch

```sh
paru -S zsh neovim eza bat fd fzf zoxide starship ripgrep
```

### Ubuntu

```sh
sudo apt install zsh neovim eza bat fd-find fzf ripgrep
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -sS https://starship.rs/install.sh | sh
ln -s "$(command -v batcat)" ~/.local/bin/bat
ln -s "$(command -v fdfind)" ~/.local/bin/fd
```

### macOS

```sh
# Run this first only when Homebrew is not already installed.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install zsh neovim eza bat fd fzf zoxide starship ripgrep
```

## Setup

Clone the dotfiles repository, then point zsh at its configuration:

```sh
mkdir -p ~/.config
git clone git@github.com:pohanhuang/dotfiles.git ~/.config/dotfiles
ln -sfn ~/.config/dotfiles/zsh ~/.config/zsh
ln -sfn ~/.config/zsh/.zshenv ~/.zshenv
chsh -s "$(command -v zsh)"
exec zsh
```

`~/.zshenv` bootstraps `ZDOTDIR=~/.config/zsh`; no `/etc/zsh/zshenv` change is needed. The first interactive shell clones the configured plugins. Create `~/.config/zsh/local.zsh` for settings that belong only to the current machine.

## Configuration

| Path | Purpose |
|---|---|
| `.zshenv` | `ZDOTDIR`, XDG paths, editor, pager, and base `PATH` |
| `.zshrc` | History, completion, module loading, and startup order |
| `aliases.zsh` | General aliases and shell functions |
| `fzf.zsh` | fzf search and preview settings |
| `bindings.zsh` | zsh keybindings |
| `plugins.zsh` | Plugin download, loading, and update function |
| `prompt.zsh` / `starship.toml` | Starship prompt setup and appearance |
| `.zshrc.d/*.zsh` | Shared work helpers loaded by every machine |
| `local.zsh` | Machine-only overrides; ignored by Git and loaded last |

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

Use the `.zsh` extension because these files are interpreted by zsh. The extension does not change how `source` works; it makes zsh-specific syntax obvious. Files are loaded alphabetically, so avoid dependencies between modules. Put a local override in `local.zsh`, which loads after all shared modules.

## Plugins

No third-party plugin manager is required. `plugins.zsh` clones missing plugins into `$ZDOTDIR/plugins/` on the first shell launch; that directory is ignored by Git. `git` and network access are required only for the first install and later updates.

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

## Keybindings

| Key | Action |
|---|---|
| `Ctrl+R` | Fuzzy history search (fzf) |
| `Ctrl+F` | Fuzzy file search excluding hidden files (fzf + fd) |
| `Ctrl+→` | Move forward one word |
| `Ctrl+←` | Move backward one word |
| `↑` / `↓` | History search by prefix |
| `Ctrl+\` | Toggle autosuggestions |

Starship requires a [Nerd Font](https://www.nerdfonts.com) for the icons in `starship.toml`.
