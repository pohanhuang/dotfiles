#!/bin/bash
# Diagnostic script to test clipboard functionality

echo "=== Clipboard Diagnostic ==="
echo ""

echo "1. Environment:"
echo "   TMUX: ${TMUX:-not set}"
echo "   TERM: ${TERM:-not set}"
echo "   SSH_CONNECTION: ${SSH_CONNECTION:-not set}"
echo ""

echo "2. TTY status:"
tty 2>&1 | sed 's/^/   /'
echo ""

if [ -n "$TMUX" ]; then
  echo "3. Tmux client TTY:"
  tmux display -p '   #{client_tty}' 2>&1
  echo ""

  echo "4. Tmux settings:"
  tmux show -g set-clipboard 2>&1 | sed 's/^/   /'
  tmux show -g allow-passthrough 2>&1 | sed 's/^/   /'
  echo ""
fi

echo "5. Clipboard tools:"
for cmd in xclip xsel wl-copy pbcopy; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "   ✓ $cmd: $(which $cmd)"
  else
    echo "   ✗ $cmd: not found"
  fi
done
echo ""

echo "6. Testing OSC 52 sequence:"
test_text="clipboard-test-$$"
encoded=$(printf '%s' "$test_text" | base64 | tr -d '\n')

if [ -n "$TMUX" ]; then
  # In tmux - use DCS wrapper
  TTY=$(tmux display -p '#{client_tty}' 2>/dev/null)
  echo "   Sending to: $TTY"
  if [ -n "$TTY" ] && [ -e "$TTY" ]; then
    printf '\033Ptmux;\033\033]52;c;%s\007\033\\' "$encoded" > "$TTY" 2>&1 && \
      echo "   ✓ OSC 52 sequence sent successfully" || \
      echo "   ✗ Failed to send OSC 52 sequence"
  else
    echo "   ✗ TTY not accessible"
  fi
else
  # Not in tmux - use plain OSC 52
  echo "   Sending to: /dev/tty"
  if [ -e "/dev/tty" ]; then
    printf '\033]52;c;%s\007' "$encoded" > /dev/tty 2>&1 && \
      echo "   ✓ OSC 52 sequence sent successfully" || \
      echo "   ✗ Failed to send OSC 52 sequence"
  else
    echo "   ✗ /dev/tty not accessible"
  fi
fi

echo ""
echo "7. If copy worked, your clipboard should contain: $test_text"
echo "   Try pasting to verify!"
echo ""
echo "=== Diagnostic Complete ==="
