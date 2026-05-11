#!/bin/bash
# Demonstrates tab tracking (Rule 2)
# Usage: ./multi-tab-demo.sh "https://example.com"

set -euo pipefail

URL="${1:?Usage: $0 <url>}"

# Rule 1: Session
SESSION="tabs-$(date +%s)-$RANDOM"

# Rule 3: Cleanup
trap "agent-browser --session '$SESSION' close 2>/dev/null || true" EXIT

# Navigate
agent-browser --session "$SESSION" open "$URL"
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

echo "Initial page loaded. Clicking first link..."

# Click link (might open new tab)
agent-browser --session "$SESSION" click @e1

# Rule 2: Check tabs
echo "Checking for new tabs..."
TABS=$(agent-browser --session "$SESSION" tab)
echo "$TABS"

TAB_COUNT=$(echo "$TABS" | wc -l)
if [ "$TAB_COUNT" -gt 1 ]; then
    echo "New tab detected! Switching..."
    agent-browser --session "$SESSION" tab $((TAB_COUNT - 1))
    agent-browser --session "$SESSION" wait --load networkidle
    agent-browser --session "$SESSION" snapshot -i

    echo "Content from new tab:"
    agent-browser --session "$SESSION" get text body | head -20

    # Return to original
    agent-browser --session "$SESSION" tab close
    agent-browser --session "$SESSION" tab 1
else
    echo "No new tab. Navigation in same tab."
    agent-browser --session "$SESSION" wait --load networkidle
    agent-browser --session "$SESSION" snapshot -i
fi

echo "Demo complete."
