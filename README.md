# Dotfiles

## Pi setup

```bash
git clone https://github.com/YOUR-USER/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install-pi.sh
```

This installs the ADHD, Ponytail, and web-access Pi packages, then symlinks these personal extensions into `~/.pi/agent/extensions/`:

- `rtk.ts` — requires `rtk >= 0.23.0` in `PATH`
- `plan-mode.ts` — `/plan` and `/save-plan`
- `pi-usage/` — `/usage` and `/usage pin`

Private Pi sessions, credentials, and `~/.pi/agent/usage/events.jsonl` are intentionally not tracked.
