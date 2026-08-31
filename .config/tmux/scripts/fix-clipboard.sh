#!/bin/bash
# Quick fix script for clipboard issues

echo "=== Clipboard Quick Fix ==="
echo ""

# 1. Make sure yank script is executable
echo "1. Checking yank-osc52.sh permissions..."
if [ -x ~/.config/tmux/scripts/yank-osc52.sh ]; then
  echo "   ✓ yank-osc52.sh is executable"
else
  echo "   ⚠ Making yank-osc52.sh executable..."
  chmod +x ~/.config/tmux/scripts/yank-osc52.sh
  echo "   ✓ Fixed"
fi
echo ""

# 2. Reload tmux config if in tmux
if [ -n "$TMUX" ]; then
  echo "2. Reloading tmux configuration..."
  tmux source-file ~/.tmux.conf 2>&1 | sed 's/^/   /'
  echo "   ✓ tmux config reloaded"
  echo ""

  echo "3. Verifying tmux settings..."
  set_clipboard=$(tmux show -gv set-clipboard 2>/dev/null)
  allow_passthrough=$(tmux show -gv allow-passthrough 2>/dev/null)

  if [ "$set_clipboard" = "external" ]; then
    echo "   ✓ set-clipboard: $set_clipboard"
  else
    echo "   ✗ set-clipboard: $set_clipboard (should be 'external')"
  fi

  if [ "$allow_passthrough" = "on" ]; then
    echo "   ✓ allow-passthrough: $allow_passthrough"
  else
    echo "   ✗ allow-passthrough: $allow_passthrough (should be 'on')"
  fi
  echo ""
else
  echo "2. Not in tmux session - skipping tmux checks"
  echo ""
fi

# 3. Test OSC 52
echo "4. Testing OSC 52 clipboard..."
test_text="clipboard-fix-$$"
echo "   Test string: $test_text"

~/.config/tmux/scripts/test-clipboard.sh

echo ""
echo "=== Next Steps ==="
echo ""
echo "If clipboard still doesn't work, check on your Mac (WezTerm):"
echo ""
echo "1. WezTerm Config (~/.wezterm.lua on Mac):"
echo "   Add this line:"
echo "   enable_clipboard_overload = true,"
echo ""
echo "2. Restart WezTerm after config change"
echo ""
echo "3. Reconnect SSH and create new tmux session:"
echo "   tmux new -s clipboard-test"
echo ""
echo "4. Test in Neovim:"
echo "   nvim test.txt"
echo "   (in Neovim) :let @+ = 'test-from-nvim'"
echo "   (on Mac) Try Cmd+V to paste"
echo ""
echo "See: ~/.config/cheat-sheet/clipboard-troubleshooting.md"
