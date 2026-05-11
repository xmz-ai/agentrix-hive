#!/bin/bash
# Base template following all 5 mandatory rules
# Copy and adapt this for your use case

set -euo pipefail

# Rule 1: Session management (REQUIRED)
SESSION="agent-$(date +%s)-$RANDOM"

# Rule 3: Cleanup (REQUIRED)
trap "agent-browser --session '$SESSION' close 2>/dev/null || true" EXIT

# Rule 4: Navigate and wait (REQUIRED)
agent-browser --session "$SESSION" open "https://example.com"
agent-browser --session "$SESSION" wait --load networkidle

# Rule 5: Snapshot (REQUIRED)
agent-browser --session "$SESSION" snapshot -i

# TODO: Interact with page
# agent-browser --session "$SESSION" click @e1
# agent-browser --session "$SESSION" fill @e2 "text"
# agent-browser --session "$SESSION" select @e3 "option"

# Rule 2: Check tabs after clicks (REQUIRED if clicking)
# agent-browser --session "$SESSION" tab

# Rule 5: Re-snapshot after navigation (REQUIRED if page changed)
# agent-browser --session "$SESSION" wait --load networkidle
# agent-browser --session "$SESSION" snapshot -i

# TODO: Extract data
# agent-browser --session "$SESSION" get text body > output.txt
# agent-browser --session "$SESSION" screenshot result.png

# Cleanup happens automatically via trap
echo "Done"
