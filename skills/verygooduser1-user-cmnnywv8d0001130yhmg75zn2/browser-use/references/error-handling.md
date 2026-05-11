# Error Handling

Common errors and recovery strategies for browser automation.

**⚠️ IMPORTANT**: All examples MUST use `--session` flag (Rule 1).

## Human Verification (CAPTCHA)

### Problem

Search engines (Bing, Google) may trigger human verification when detecting bot-like behavior.

**Symptoms:**
- Page shows "Verify you are human" or "One last step"
- `snapshot -i` returns only navigation elements, no search results
- Search results don't appear after waiting

### Detection

```bash
# Take screenshot to check for CAPTCHA
mkdir -p ./tmp
agent-browser --session "$SESSION" screenshot ./tmp/debug.png
# View the image to see if CAPTCHA is present

# Cleanup when done
rm -rf ./tmp

# Close browser when done
agent-browser --session "$SESSION" close
```

### Causes

1. **Direct search URL access** - Going directly to `bing.com/search?q=...` triggers detection
2. **Headless mode** - Bot detection is more aggressive in headless mode
3. **Rapid requests** - Too many searches in short time
4. **Missing browser fingerprint** - Default headless settings look like bots

### Solutions

**Solution 1: Visit homepage first, then search**

```bash
SESSION="search-$(date +%s)-$RANDOM"

# ✅ CORRECT - Visit homepage first
agent-browser --session "$SESSION" open "https://www.bing.com"
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# Find search box and fill
agent-browser --session "$SESSION" fill @e18 "your search query"
agent-browser --session "$SESSION" press Enter
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# ❌ WRONG - Direct search URL (triggers CAPTCHA)
# agent-browser --session "$SESSION" open "https://www.bing.com/search?q=..."
```

**Solution 2: Use headed mode**

```bash
SESSION="search-$(date +%s)-$RANDOM"

# Headed mode is less likely to trigger CAPTCHA
agent-browser --session "$SESSION" --headed open "https://www.bing.com"

# Close browser when done
agent-browser --session "$SESSION" close
```

**Solution 3: Add delays between actions**

```bash
agent-browser --session "$SESSION" fill @e18 "query"
agent-browser --session "$SESSION" wait 1000  # Brief pause
agent-browser --session "$SESSION" press Enter

# Close browser when done
agent-browser --session "$SESSION" close
```

### Verification Check Pattern

```bash
# After search, verify results loaded (not CAPTCHA)
agent-browser --session "$SESSION" snapshot -i > ./tmp/snapshot.txt

# Check if we got real results or just navigation
if grep -q "Verify you are human" ./tmp/snapshot.txt; then
    echo "CAPTCHA detected!"
    agent-browser --session "$SESSION" screenshot ./tmp/captcha.png
    # Handle: retry with headed mode, or wait and retry
fi

# Close browser when done
agent-browser --session "$SESSION" close
```

---

## Element Not Found

### Problem

`snapshot -i` shows elements, but interaction fails with "element not found".

### Causes

1. **Stale refs** - Page changed after snapshot (Rule 5)
2. **Element not in viewport** - Need to scroll first
3. **Dynamic loading** - Element appeared after snapshot

### Solutions

```bash
# Re-snapshot after any page change
agent-browser --session "$SESSION" snapshot -i

# Scroll to reveal elements
agent-browser --session "$SESSION" scroll down 300
agent-browser --session "$SESSION" snapshot -i

# Wait for dynamic content
agent-browser --session "$SESSION" wait 2000
agent-browser --session "$SESSION" snapshot -i

# Close browser when done
agent-browser --session "$SESSION" close
```

---

## Empty Snapshot

### Problem

`snapshot -i` returns "(no interactive elements)".

### Causes

1. **Page not loaded** - Snapshot too early
2. **Wrong viewport** - Elements outside visible area
3. **Dynamic page** - Content loads via JavaScript

### Solutions

```bash
# Wait for page load
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# If still empty, wait fixed time
agent-browser --session "$SESSION" wait 2000
agent-browser --session "$SESSION" snapshot -i

# Scroll to trigger lazy loading
agent-browser --session "$SESSION" scroll down 200
agent-browser --session "$SESSION" snapshot -i

# Close browser when done
agent-browser --session "$SESSION" close
```

---

## Network Idle Timeout

### Problem

`wait --load networkidle` hangs indefinitely or times out.

### Causes

1. **Continuous network activity** - Ads, tracking, live updates
2. **Streaming content** - Video, WebSocket connections
3. **Polling APIs** - Page constantly fetching data
4. **Search engines** - Bing, Google constantly load suggestions

### Solutions

**⚠️ RECOMMENDED: Use fixed wait times instead of networkidle**

```bash
# PREFERRED - Fixed wait (most reliable)
agent-browser --session "$SESSION" open "https://example.com"
agent-browser --session "$SESSION" wait 2000  # 2 seconds
agent-browser --session "$SESSION" snapshot -i

# For complex pages
agent-browser --session "$SESSION" wait 3000  # 3 seconds
agent-browser --session "$SESSION" wait 5000  # 5 seconds for heavy pages

# If you must use networkidle, always add timeout
agent-browser --session "$SESSION" wait --load networkidle --timeout 5000
# If timeout occurs, proceed anyway - page is usually ready
agent-browser --session "$SESSION" snapshot -i

# Wait for specific element (alternative)
agent-browser --session "$SESSION" wait @e1 --timeout 10000

# Close browser when done
agent-browser --session "$SESSION" close
```

**Guideline**: Default to `wait 2000` or `wait 3000`. Only use `networkidle` with timeout if you specifically need to wait for all network activity to stop.

---

## New Tab Not Detected

### Problem

Click opened new tab, but automation continues on old tab.

### Causes

1. **Forgot to check tabs** (Rule 2)
2. **Tab opened in background**

### Solutions

```bash
# Always check tabs after clicks (Rule 2)
agent-browser --session "$SESSION" click @e5
agent-browser --session "$SESSION" tab  # List tabs

# Switch to new tab if detected
TABS=$(agent-browser --session "$SESSION" tab)
TAB_COUNT=$(echo "$TABS" | wc -l)
if [ "$TAB_COUNT" -gt 1 ]; then
    agent-browser --session "$SESSION" tab $((TAB_COUNT - 1))
    agent-browser --session "$SESSION" wait --load networkidle
    agent-browser --session "$SESSION" snapshot -i
fi

# Close browser when done
agent-browser --session "$SESSION" close
```

---

## Session Already Closed

### Problem

Commands fail with "session not found" or similar error.

### Causes

1. **Explicit close** - Session was closed earlier
2. **Browser crash** - Browser process died
3. **Timeout** - Session expired

### Solutions

```bash
# Track session state
SESSION_OPEN=false

open_session() {
    agent-browser --session "$SESSION" open "$1"
    SESSION_OPEN=true
}

close_session() {
    if [ "$SESSION_OPEN" = true ]; then
        agent-browser --session "$SESSION" close 2>/dev/null || true
        SESSION_OPEN=false
    fi
}

```

---

## Debugging Tips

### 1. Always Screenshot on Error

```bash
# When something fails, capture state
agent-browser --session "$SESSION" screenshot ./tmp/error-$(date +%s).png

# Close browser when done
agent-browser --session "$SESSION" close
```

### 2. Use Headed Mode for Debugging

```bash
# See what's happening visually
agent-browser --session "$SESSION" --headed open "https://example.com"

# Close browser when done
agent-browser --session "$SESSION" close
```

### 3. Check Current URL

```bash
# Verify you're on expected page
agent-browser --session "$SESSION" get url

# Close browser when done
agent-browser --session "$SESSION" close
```

### 4. List Active Sessions

```bash
# Check for orphaned sessions
agent-browser session list

# Close browser when done
agent-browser --session "$SESSION" close
```
