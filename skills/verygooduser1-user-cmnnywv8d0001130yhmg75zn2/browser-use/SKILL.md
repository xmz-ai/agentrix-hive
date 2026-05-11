---
name: browser-use
description: Browser automation with mandatory session management and tab tracking. Use for web research, data extraction, form interaction, or any browser task. Enforces strict session isolation and proper cleanup.
allowed-tools: Bash(agent-browser:*)
---

# Browser-Use: Agent Browser Automation

Browser automation for agents with **mandatory session management** and **tab tracking**.

## Core Differences from agent-browser

This skill extends the official `agent-browser` with **2 mandatory requirements**:

1. **Sessions are REQUIRED** (not optional) - ensures isolation between concurrent agents
2. **Tab tracking is REQUIRED** - detects when clicks open new tabs

All other patterns follow the official agent-browser skill.

---

## ⚠️ Important: Human Verification (CAPTCHA)

Search engines (Bing, Google) may trigger human verification when detecting bot-like behavior.

**Common triggers:**
- **Direct search URL access** - Going directly to `bing.com/search?q=...`
- **Headless mode** - Bot detection is more aggressive without visible browser
- **Rapid requests** - Too many searches in short time

**Solutions:**
1. **Visit homepage first, then search** (don't use direct search URLs)
2. **Use `--headed` mode** for search engines
3. **Add delays** between actions

**Detection:**
```bash
# If snapshot shows only navigation (no results), take screenshot to check
mkdir -p ./tmp
agent-browser --session "$SESSION" screenshot ./tmp/debug.png
# Look for "Verify you are human" message
# Cleanup when done: rm -rf ./tmp
```

See [references/error-handling.md](references/error-handling.md) for detailed solutions.

---

## The 5 Mandatory Rules

### Rule 1: Always Use Sessions

**Every command MUST use `--session` flag.**

```bash
# Generate session ID (simple random)
SESSION="agent-$(date +%s)-$RANDOM"

# All commands use session
agent-browser --session "$SESSION" open "https://example.com"
agent-browser --session "$SESSION" snapshot -i
agent-browser --session "$SESSION" click @e1

# Close when done
agent-browser --session "$SESSION" close
```

**Why**: Prevents state collision between concurrent agents in different workspaces.

---

### Rule 2: Always Check Tabs After Clicks

**After clicking, check if new tab op ened.**

```bash
# Click might open new tab
agent-browser --session "$SESSION" click @e5

# MUST check tabs
agent-browser --session "$SESSION" tab

# If output shows multiple tabs, switch to new one:
# → [0] https://example.com (current tab)
#   [1] https://example.com/details (new tab)

# Tab numbers start from 0!
agent-browser --session "$SESSION" tab 1  # Switch to tab 1 (the second tab)
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i
```

**Why**: Links with `target="_blank"`, OAuth flows, and JavaScript can open new tabs. If ignored, you automate the wrong page.

---

### Rule 3: Always Close Browser When Done

**Always close the browser session AFTER all browser work is complete.**

```bash
# Work freely - browser stays open for all operations
agent-browser --session "$SESSION" open "https://example.com"
agent-browser --session "$SESSION" snapshot -i
agent-browser --session "$SESSION" click @e1
# ... do all your work ...

# Close browser when all work is complete
agent-browser --session "$SESSION" close
```

**IMPORTANT**: Close the browser **after finishing all operations**, NOT immediately after opening. Keep the browser open for your entire workflow, then close it at the end.

**Why**: Prevents resource leaks and zombie browser processes.

---

### Rule 4: Wait for Page Load

**Wait for page to finish loading before interacting.**

```bash
agent-browser --session "$SESSION" open "https://example.com"
agent-browser --session "$SESSION" wait 2000  # Fixed wait (recommended)
agent-browser --session "$SESSION" snapshot -i
```

**⚠️ IMPORTANT**: `wait --load networkidle` often hangs on pages with ads, tracking, or live content. **Prefer fixed wait times**:
- Simple pages: `wait 2000` (2 seconds)
- Complex pages: `wait 3000-5000`
- If using networkidle, add timeout: `wait --load networkidle --timeout 5000`

If networkidle times out, proceed with snapshot anyway - the page is usually ready.

**Apply after**:
- `open` commands
- Navigation (clicking links)
- Tab switches

**Why**: Modern pages load asynchronously. Snapshotting too early gives incomplete/incorrect refs.

---

### Rule 5: Re-snapshot After Page Changes

**Get fresh refs after navigation.**

```bash
agent-browser --session "$SESSION" click @e3   # Navigates to new page
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i # Get new refs
agent-browser --session "$SESSION" click @e1   # Use new refs
```

**Refs are invalidated by**:
- Navigation
- Tab switches
- Dynamic content loading (modals, dropdowns)

**Why**: Old refs point to elements that no longer exist or are different.

---

## Complete Workflow Template

```bash
#!/bin/bash
set -euo pipefail

# 1. Generate session ID (Rule 1)
SESSION="agent-$(date +%s)-$RANDOM"

# 2. Navigate and wait (Rule 4)
agent-browser --session "$SESSION" open "https://example.com"
agent-browser --session "$SESSION" wait --load networkidle

# 3. Snapshot (Rule 5)
agent-browser --session "$SESSION" snapshot -i

# 4. Interact with tab checking (Rule 2)
agent-browser --session "$SESSION" click @e1
agent-browser --session "$SESSION" tab  # Check for new tabs

# If new tab detected (tab count > 1):
# agent-browser --session "$SESSION" tab 1
# agent-browser --session "$SESSION" wait --load networkidle

# 5. Re-snapshot after navigation (Rule 5)
agent-browser --session "$SESSION" snapshot -i

# 6. Extract data
agent-browser --session "$SESSION" get text body > results.txt

# 7. Continue doing more work if needed...
# Browser stays open for all operations

# 8. Close browser when all work is complete (Rule 3)
agent-browser --session "$SESSION" close
```

---

## Common Patterns

### Web Search

**⚠️ Don't use direct search URLs - triggers CAPTCHA. Visit homepage first.**

```bash
SESSION="search-$(date +%s)-$RANDOM"

# 1. Visit homepage first (avoid CAPTCHA)
agent-browser --session "$SESSION" --headed open "https://www.bing.com"
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# 2. Find search box (usually @e18 or similar textbox)
agent-browser --session "$SESSION" fill @e18 "your search query"
agent-browser --session "$SESSION" press Enter

# 3. Wait for results
agent-browser --session "$SESSION" wait --load networkidle

# 4. Scroll to see results (snapshot may only show navigation initially)
agent-browser --session "$SESSION" scroll down 200
agent-browser --session "$SESSION" snapshot -i

# 5. Click result and check tabs (Rule 2)
agent-browser --session "$SESSION" click @e50
agent-browser --session "$SESSION" tab

# 6. Close browser when done
agent-browser --session "$SESSION" close
```

**Why `--headed` mode?** Headless browsers are more likely to trigger bot detection on search engines.

### Form Filling

```bash
SESSION="form-$(date +%s)-$RANDOM"

agent-browser --session "$SESSION" open "https://example.com/form"
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

agent-browser --session "$SESSION" fill @e1 "Name"
agent-browser --session "$SESSION" fill @e2 "email@example.com"
agent-browser --session "$SESSION" select @e3 "Option"
agent-browser --session "$SESSION" click @e4  # Submit

# Check for new tabs (Rule 2)
agent-browser --session "$SESSION" tab

agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# Close browser when done
agent-browser --session "$SESSION" close
```

### Multi-Tab Navigation

```bash
SESSION="tabs-$(date +%s)-$RANDOM"

agent-browser --session "$SESSION" open "https://example.com"
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# Click link
agent-browser --session "$SESSION" click @e1

# Check tabs (Rule 2)
TABS=$(agent-browser --session "$SESSION" tab)
TAB_COUNT=$(echo "$TABS" | wc -l)

if [ "$TAB_COUNT" -gt 1 ]; then
    echo "New tab detected"
    agent-browser --session "$SESSION" tab $((TAB_COUNT - 1))
    agent-browser --session "$SESSION" wait --load networkidle
    agent-browser --session "$SESSION" snapshot -i

    # Extract from new tab
    agent-browser --session "$SESSION" get text body

    # Close tab and return
    agent-browser --session "$SESSION" tab close
    agent-browser --session "$SESSION" tab 0
fi

# Close browser when done
agent-browser --session "$SESSION" close
```

### Login Once, Reuse State

```bash
SESSION="auth-$(date +%s)-$RANDOM"
STATE_FILE="./auth-state.json"

if [ -f "$STATE_FILE" ]; then
    # Restore saved session
    agent-browser --session "$SESSION" state load "$STATE_FILE"
    agent-browser --session "$SESSION" open "https://app.com/dashboard"
else
    # Perform login
    agent-browser --session "$SESSION" open "https://app.com/login"
    agent-browser --session "$SESSION" wait --load networkidle
    agent-browser --session "$SESSION" snapshot -i

    agent-browser --session "$SESSION" fill @e1 "$USERNAME"
    agent-browser --session "$SESSION" fill @e2 "$PASSWORD"
    agent-browser --session "$SESSION" click @e3
    agent-browser --session "$SESSION" wait --url "**/dashboard"

    # Save for future use
    agent-browser --session "$SESSION" state save "$STATE_FILE"
fi

agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# Close browser when done
agent-browser --session "$SESSION" close
```

---

## When to Use This Skill

### Embla Uses It When:
- Researching GitHub, docs, examples for agent design
- Gathering current information (news, trends, APIs)
- Finding similar agents or tools
- Any task requiring live internet data

### Created Agents Use It When:
- User asks to "search", "browse", "find online", "look up"
- Agent's domain requires web interaction:
  - Design agent → Browse design sites
  - Shopping agent → Browse products
  - News agent → Search articles
  - Research agent → Gather documentation

---

## Error Handling

### Human Verification (CAPTCHA) on Search Engines

**Symptoms**: Snapshot shows only navigation, no search results.

**Cause**: Bot detection triggered by direct URL or headless mode.

**Solution**:
1. Visit homepage first, then search
2. Use `--headed` mode
3. Screenshot to verify: `agent-browser --session "$SESSION" screenshot ./tmp/debug.png`

### Element Not Found After Click

**Cause**: New tab opened but didn't switch.

**Solution**: Always check tabs (Rule 2).

### Stale Refs

**Cause**: Reusing refs after page changed.

**Solution**: Re-snapshot after navigation (Rule 5).

### Session Resource Leaks

**Cause**: Forgot to close session.

**Solution**: Always close browser when done (Rule 3): `agent-browser --session "$SESSION" close`

### Empty Snapshot

**Cause**: Snapshotted before page loaded, or need to scroll.

**Solution**:
1. Wait for networkidle (Rule 4)
2. Scroll down and re-snapshot: `agent-browser --session "$SESSION" scroll down 200`

See [references/error-handling.md](references/error-handling.md) for comprehensive error handling guide.

---

## Quick Command Reference

See [references/commands.md](references/commands.md) for full command list.

**Essential commands:**

```bash
# Session (Rule 1)
SESSION="agent-$(date +%s)-$RANDOM"

# Navigate (Rule 4)
agent-browser --session "$SESSION" open <url>
agent-browser --session "$SESSION" wait --load networkidle

# Snapshot (Rule 5)
agent-browser --session "$SESSION" snapshot -i

# Interact
agent-browser --session "$SESSION" click @e1
agent-browser --session "$SESSION" fill @e2 "text"
agent-browser --session "$SESSION" select @e3 "option"

# Tab management (Rule 2)
agent-browser --session "$SESSION" tab
agent-browser --session "$SESSION" tab 1
agent-browser --session "$SESSION" tab close

# Get data
agent-browser --session "$SESSION" get text @e1
agent-browser --session "$SESSION" get text body
agent-browser --session "$SESSION" get url

# Close when done (Rule 3)
agent-browser --session "$SESSION" close
```

---

## Official Documentation

For detailed command reference, advanced patterns, and troubleshooting, see the official agent-browser skill documentation:

- **Full command reference**: Use `snapshot`, `click`, `fill`, `select`, `wait`, `get`, etc.
- **Authentication patterns**: Login flows, OAuth, state persistence
- **Advanced features**: Video recording, proxy support, iOS simulator

This skill follows all agent-browser patterns with 2 additions: **mandatory sessions** and **mandatory tab checking**.

---

## Summary

**This skill = agent-browser + 2 mandatory rules:**

1. ✅ **Always use sessions** (generate with `$(date +%s)-$RANDOM`)
2. ✅ **Always check tabs after clicks** (use `agent-browser tab`)

Plus the standard browser automation best practices:
3. ✅ Always close browser when done
4. ✅ Wait for networkidle after navigation
5. ✅ Re-snapshot after page changes

**Key pattern:**
```bash
SESSION="agent-$(date +%s)-$RANDOM"
# ... use session in all commands ...
# ... do all your browser work ...
# Close browser after all work is complete
agent-browser --session "$SESSION" close
```
