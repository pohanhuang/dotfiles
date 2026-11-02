# Dotfiles
## Installation
```bash
mkdir -p ~/.config
git clone git@github.com:pohanhuang/dotfiles.git ~/.config/dotfiles

brew install neovim
brew install lazygit
curl -fsSL https://herdr.dev/install.sh | sh

ln -s ~/.config/dotfiles/nvim     ~/.config/nvim
ln -s ~/.config/dotfiles/lazygit  ~/.config/lazygit
ln -s ~/.config/dotfiles/herdr    ~/.config/herdr
```

## Pi setup

```bash
git clone https://github.com/YOUR-USER/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install-pi.sh

pi install npm:@po.dev/pi-usage-dashboard
pi install npm:@po.dev/pi-branch-workspace
pi install npm:@po.dev/pi-ask-me
pi install npm:pi-claude-bridge
```

This installs the ADHD, Ponytail, and web-access Pi packages, then symlinks these personal extensions into `~/.pi/agent/extensions/`:

- `rtk.ts` — requires `rtk >= 0.23.0` in `PATH`
- `plan-mode.ts` — `/plan` and `/save-plan`
- `pi-usage/` — `/usage` and `/usage pin`

Private Pi sessions, credentials, and `~/.pi/agent/usage/events.jsonl` are intentionally not tracked.

## herdr setup (new machine)

```bash
# 0. Back up any existing config
mv ~/.config/herdr ~/.config/herdr.bak

# 1. Symlink (required)
ln -sfn ~/.config/dotfiles/herdr ~/.config/herdr

# 2. Source it (herdr.sh says "source in ~/.zshrc"; bash works too)
echo '[ -f ~/.config/herdr/herdr.sh ] && . ~/.config/herdr/herdr.sh' >> ~/.bashrc

# 3. Check dependencies (ha/hd need all three)
command -v fzf zoxide python3

# 4. Verify
exec bash && type hd && hd .
```
