# Session Management

**⚠️ MANDATORY**: All browser commands MUST use `--session` flag (Rule 1).

Multiple isolated browser sessions with state persistence and concurrent browsing.

**Related**: [authentication.md](authentication.md) for login patterns, [SKILL.md](../SKILL.md) for quick start.

## Session ID Generation (REQUIRED)

```bash
# Simple random generation (recommended)
SESSION="agent-$(date +%s)-$RANDOM"

# Examples:
# SESSION="search-1738761234-12345"
# SESSION="form-1738761235-54321"
```

## Session Isolation

Each named session has independent:
- Cookies
- LocalStorage / SessionStorage
- IndexedDB
- Cache
- Browsing history
- Open tabs

```bash
# Session 1: Authentication flow
SESSION_A="auth-$(date +%s)-$RANDOM"
agent-browser --session "$SESSION_A" open https://app.example.com/login

# Session 2: Public browsing (separate cookies, storage)
SESSION_B="public-$(date +%s)-$RANDOM"
agent-browser --session "$SESSION_B" open https://example.com

# Completely isolated - no interference

# Close sessions when done
agent-browser --session "$SESSION_A" close
agent-browser --session "$SESSION_B" close
```

## State Persistence

### Save Session State

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# Save cookies, storage, and auth state
agent-browser --session "$SESSION" state save /path/to/auth-state.json

# Close browser when done
agent-browser --session "$SESSION" close
```

### Load Session State

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# Restore saved state
agent-browser --session "$SESSION" state load /path/to/auth-state.json

# Continue with authenticated session
agent-browser --session "$SESSION" open https://app.example.com/dashboard

# Close browser when done
agent-browser --session "$SESSION" close
```

## Common Patterns

### Authenticated Session Reuse

```bash
#!/bin/bash
SESSION="agent-$(date +%s)-$RANDOM"
STATE_FILE="/tmp/auth-state.json"

# Check if we have saved state
if [[ -f "$STATE_FILE" ]]; then
    agent-browser --session "$SESSION" state load "$STATE_FILE"
    agent-browser --session "$SESSION" open https://app.example.com/dashboard
else
    # Perform login
    agent-browser --session "$SESSION" open https://app.example.com/login
    agent-browser --session "$SESSION" snapshot -i
    agent-browser --session "$SESSION" fill @e1 "$USERNAME"
    agent-browser --session "$SESSION" fill @e2 "$PASSWORD"
    agent-browser --session "$SESSION" click @e3
    agent-browser --session "$SESSION" wait --load networkidle

    # Save for future use
    agent-browser --session "$SESSION" state save "$STATE_FILE"
fi

# Close browser when done
agent-browser --session "$SESSION" close
```

### Concurrent Scraping

```bash
#!/bin/bash
# Scrape multiple sites concurrently

SESSION1="site1-$(date +%s)-$RANDOM"
SESSION2="site2-$(date +%s)-$RANDOM"
SESSION3="site3-$(date +%s)-$RANDOM"

# Start all sessions
agent-browser --session "$SESSION1" open https://site1.com &
agent-browser --session "$SESSION2" open https://site2.com &
agent-browser --session "$SESSION3" open https://site3.com &
wait

# Extract from each
agent-browser --session "$SESSION1" get text body > site1.txt
agent-browser --session "$SESSION2" get text body > site2.txt
agent-browser --session "$SESSION3" get text body > site3.txt

# Close all sessions when done
agent-browser --session "$SESSION1" close
agent-browser --session "$SESSION2" close
agent-browser --session "$SESSION3" close
```

### A/B Testing Sessions

```bash
SESSION_A="variant-a-$(date +%s)-$RANDOM"
SESSION_B="variant-b-$(date +%s)-$RANDOM"

# Test different user experiences
agent-browser --session "$SESSION_A" open "https://app.com?variant=a"
agent-browser --session "$SESSION_B" open "https://app.com?variant=b"

# Compare
agent-browser --session "$SESSION_A" screenshot /tmp/variant-a.png
agent-browser --session "$SESSION_B" screenshot /tmp/variant-b.png

# Cleanup
agent-browser --session "$SESSION_A" close
agent-browser --session "$SESSION_B" close
```

## Session Cleanup (REQUIRED)

**Always close sessions when done (Rule 3):**

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# Work freely
agent-browser --session "$SESSION" open https://example.com
# ... automation ...

# Close browser when done
agent-browser --session "$SESSION" close
```

## Best Practices

### 1. Always Use Sessions (Rule 1)

```bash
# ✅ CORRECT
SESSION="agent-$(date +%s)-$RANDOM"
agent-browser --session "$SESSION" open https://example.com

# ❌ WRONG - Default session not allowed
agent-browser open https://example.com
```

### 2. Use Descriptive Prefixes

```bash
# GOOD: Clear purpose
SESSION="github-research-$(date +%s)-$RANDOM"
SESSION="oauth-login-$(date +%s)-$RANDOM"
SESSION="price-scrape-$(date +%s)-$RANDOM"
```

### 3. Always Clean Up (Rule 3)

```bash
# Always close browser when done
agent-browser --session "$SESSION" close
```

### 4. Handle State Files Securely

```bash
# Don't commit state files (contain auth tokens!)
echo "*.auth-state.json" >> .gitignore

# Delete after use if single-use
rm -f ./auth-state.json
agent-browser --session "$SESSION" close
```

### 5. Check Active Sessions

```bash
# List all active sessions
agent-browser session list

# Example output:
# search-1738761234-12345: https://bing.com
# form-1738761235-54321: https://example.com
```
