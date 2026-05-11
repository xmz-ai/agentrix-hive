#!/bin/bash
# Generic web search following mandatory rules
# Usage: ./search-workflow.sh "search query" [engine]

set -euo pipefail

QUERY="${1:?Usage: $0 <query> [bing|google]}"
ENGINE="${2:-bing}"

# Rule 1: Session management
SESSION="search-$(date +%s)-$RANDOM"

# Rule 3: Cleanup
trap "agent-browser --session '$SESSION' close 2>/dev/null || true" EXIT

# Build search URL
case "$ENGINE" in
    bing)
        URL="https://bing.com/search?q=$(echo "$QUERY" | jq -sRr @uri)"
        ;;
    google)
        URL="https://google.com/search?q=$(echo "$QUERY" | jq -sRr @uri)"
        ;;
    *)
        echo "Unknown engine: $ENGINE"
        exit 1
        ;;
esac

echo "Searching: $QUERY on $ENGINE"

# Rule 4: Navigate and wait
agent-browser --session "$SESSION" open "$URL"
agent-browser --session "$SESSION" wait --load networkidle

# Rule 5: Snapshot
agent-browser --session "$SESSION" snapshot -i

# Extract results
echo ""
echo "Search results:"
agent-browser --session "$SESSION" get text body | head -50
