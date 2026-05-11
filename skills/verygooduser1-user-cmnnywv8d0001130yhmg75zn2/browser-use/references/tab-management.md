# Tab Management

**⚠️ MANDATORY**: Always check tabs after clicks (Rule 2). All examples use `--session` (Rule 1).

## Why Tab Tracking Matters

Modern web applications frequently open new tabs:
- Links with `target="_blank"`
- JavaScript `window.open()` calls
- OAuth/SSO redirects
- Form submissions that open results in new tab

**If you ignore new tabs**: You continue automating the WRONG page.

## Basic Tab Commands

**Tab numbers start from 0** (not 1).

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# List all tabs
agent-browser --session "$SESSION" tab
# Output (→ indicates current tab):
# → [0] https://example.com (first tab, current)
#   [1] https://example.com/page2 (second tab)

# Switch to specific tab (0-indexed)
agent-browser --session "$SESSION" tab 0  # First tab
agent-browser --session "$SESSION" tab 1  # Second tab

# Close current tab
agent-browser --session "$SESSION" tab close
```

## Detection Pattern (Rule 2)

**After ANY click, check for new tabs:**

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# Click might open new tab
agent-browser --session "$SESSION" click @e5

# MUST check tabs (Rule 2)
agent-browser --session "$SESSION" tab

# If output shows multiple tabs:
# 1: https://example.com
# 2: https://example.com/details *

# Switch to new tab
agent-browser --session "$SESSION" tab 1
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# Close browser when done
agent-browser --session "$SESSION" close
```

## Programmatic Detection

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# Store tab count before action
TABS_BEFORE=$(agent-browser --session "$SESSION" tab | wc -l)

# Perform action
agent-browser --session "$SESSION" click @e5

# Check tab count after
TABS_AFTER=$(agent-browser --session "$SESSION" tab | wc -l)

if [ "$TABS_AFTER" -gt "$TABS_BEFORE" ]; then
    echo "New tab detected!"
    agent-browser --session "$SESSION" tab "$TABS_AFTER"
    agent-browser --session "$SESSION" wait --load networkidle
    agent-browser --session "$SESSION" snapshot -i
fi

# Close browser when done
agent-browser --session "$SESSION" close
```

## Common Scenarios

### OAuth/SSO Login

```bash
SESSION="oauth-$(date +%s)-$RANDOM"

# Click "Sign in with Google"
agent-browser --session "$SESSION" open "https://app.com/login"
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i
agent-browser --session "$SESSION" click @e3

# Check tabs (Rule 2)
agent-browser --session "$SESSION" tab
# Output:
# 1: https://app.com/login
# 2: https://accounts.google.com/signin *

# Switch to OAuth tab
agent-browser --session "$SESSION" tab 1
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# Fill OAuth credentials
agent-browser --session "$SESSION" fill @e1 "user@gmail.com"
agent-browser --session "$SESSION" click @e2
agent-browser --session "$SESSION" wait 2000
agent-browser --session "$SESSION" snapshot -i
agent-browser --session "$SESSION" fill @e3 "password"
agent-browser --session "$SESSION" click @e4

# Wait for redirect back
agent-browser --session "$SESSION" wait --url "**/app.com**"

# Close browser when done
agent-browser --session "$SESSION" close
```

### Search Results Opening New Tabs

```bash
SESSION="search-$(date +%s)-$RANDOM"

agent-browser --session "$SESSION" open "https://bing.com/search?q=test"
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

# Click first result
agent-browser --session "$SESSION" click @e5

# Check tabs (Rule 2)
TABS=$(agent-browser --session "$SESSION" tab)
TAB_COUNT=$(echo "$TABS" | wc -l)

if [ "$TAB_COUNT" -gt 1 ]; then
    echo "Result opened in new tab"
    agent-browser --session "$SESSION" tab 1
    agent-browser --session "$SESSION" wait --load networkidle
    agent-browser --session "$SESSION" snapshot -i
    agent-browser --session "$SESSION" get text body > result.txt

    # Return to search
    agent-browser --session "$SESSION" tab close
    agent-browser --session "$SESSION" tab 1
else
    echo "Result opened in same tab"
    agent-browser --session "$SESSION" wait --load networkidle
    agent-browser --session "$SESSION" snapshot -i
fi
```

### Multi-Tab Comparison

```bash
SESSION="compare-$(date +%s)-$RANDOM"

agent-browser --session "$SESSION" open "https://site.com/product1"
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" get text body > product1.txt

# Open in new tab (background)
agent-browser --session "$SESSION" open "https://site.com/product2"
agent-browser --session "$SESSION" tab

# Now have 2 tabs - switch to tab 1
agent-browser --session "$SESSION" tab 1
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" get text body > product2.txt

# Compare data
echo "Comparison complete - check product1.txt and product2.txt"

# Close browser when done
agent-browser --session "$SESSION" close
```

## Best Practices

1. **Always check tabs after clicks** (Rule 2)
   ```bash
   agent-browser --session "$SESSION" click @e1
   agent-browser --session "$SESSION" tab  # Check immediately
   ```

2. **Handle both cases** (same tab / new tab)
   ```bash
   TABS_BEFORE=$(agent-browser --session "$SESSION" tab | wc -l)
   agent-browser --session "$SESSION" click @e1
   TABS_AFTER=$(agent-browser --session "$SESSION" tab | wc -l)

   if [ "$TABS_AFTER" -gt "$TABS_BEFORE" ]; then
       # New tab logic
   else
       # Same tab logic
   fi
   ```

3. **Close tabs you don't need**
   ```bash
   agent-browser --session "$SESSION" tab close
   ```

4. **Re-snapshot after tab switch** (Rule 5)
   ```bash
   agent-browser --session "$SESSION" tab 1
   agent-browser --session "$SESSION" wait --load networkidle
   agent-browser --session "$SESSION" snapshot -i  # REQUIRED
   ```

## Troubleshooting

### Element not found after click

**Cause**: New tab opened, still on old tab.

**Solution**: Check tabs (Rule 2), switch if needed.

### Click did nothing (no new tab, no navigation)

**Cause**: Click didn't trigger navigation. Common with search result links.

**Detection**:
```bash
# After click, check both tabs AND URL
agent-browser --session "$SESSION" click @e5
agent-browser --session "$SESSION" tab
URL_AFTER=$(agent-browser --session "$SESSION" get url)

# If tab count is 1 AND URL unchanged, click may have failed
```

**Solutions**:
1. **Check if new tab opened in background** - switch to it
   ```bash
   agent-browser --session "$SESSION" tab 1  # Try switching
   ```

2. **Wait and retry** - page may be slow
   ```bash
   agent-browser --session "$SESSION" wait 2000
   agent-browser --session "$SESSION" snapshot -i
   # Try clicking again with fresh ref
   ```

3. **Use different ref** - try clicking the parent link
   ```bash
   # If @e23 didn't work, try nearby refs like @e22 or @e24
   agent-browser --session "$SESSION" click @e24
   ```

4. **Verify with screenshot**
   ```bash
   mkdir -p ./tmp
   agent-browser --session "$SESSION" screenshot ./tmp/debug.png
   # Check what the page looks like
   rm -rf ./tmp
   ```

### OAuth tab closed but script waiting

**Cause**: OAuth redirect closed tab automatically.

**Solution**: Re-check tabs after OAuth action.

```bash
agent-browser --session "$SESSION" tab
# Verify you're on correct tab
```
