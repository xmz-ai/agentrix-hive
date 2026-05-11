# Command Reference

Quick reference for agent-browser commands. **All commands MUST use --session flag.**

## Session Management (REQUIRED)

```bash
# Generate session ID
SESSION="agent-$(date +%s)-$RANDOM"

# All commands use --session
agent-browser --session "$SESSION" <command>

# Cleanup when done
agent-browser --session "$SESSION" close
```

## Navigation

```bash
agent-browser --session "$SESSION" open <url>
agent-browser --session "$SESSION" back
agent-browser --session "$SESSION" forward
agent-browser --session "$SESSION" reload
agent-browser --session "$SESSION" close
```

## Snapshot

```bash
agent-browser --session "$SESSION" snapshot -i         # Interactive elements (recommended)
agent-browser --session "$SESSION" snapshot -i -C      # Include cursor-interactive
agent-browser --session "$SESSION" snapshot -s "#sel"  # Scope to selector

```

## Interactions (use @refs from snapshot)

```bash
agent-browser --session "$SESSION" click @e1
agent-browser --session "$SESSION" fill @e2 "text"
agent-browser --session "$SESSION" type @e2 "text"
agent-browser --session "$SESSION" select @e3 "option"
agent-browser --session "$SESSION" check @e1
agent-browser --session "$SESSION" press Enter
agent-browser --session "$SESSION" scroll down 500

```

## Tab Management (REQUIRED CHECK)

```bash
# Always check tabs after clicks
agent-browser --session "$SESSION" tab              # List tabs
agent-browser --session "$SESSION" tab 1            # Switch to tab 1
agent-browser --session "$SESSION" tab close        # Close current tab
```

## Get Information

```bash
agent-browser --session "$SESSION" get text @e1
agent-browser --session "$SESSION" get text body    # All page text
agent-browser --session "$SESSION" get url
agent-browser --session "$SESSION" get title

```

## Wait (REQUIRED after navigation)

```bash
agent-browser --session "$SESSION" wait --load networkidle  # After open/navigate
agent-browser --session "$SESSION" wait @e1                 # Wait for element
agent-browser --session "$SESSION" wait 2000                # Wait milliseconds
agent-browser --session "$SESSION" wait --url "**/page"     # Wait for URL

```

## Screenshots

```bash
agent-browser --session "$SESSION" screenshot
agent-browser --session "$SESSION" screenshot path.png
agent-browser --session "$SESSION" screenshot --full

```

## State Persistence

```bash
agent-browser --session "$SESSION" state save ./state.json
agent-browser --session "$SESSION" state load ./state.json

```
