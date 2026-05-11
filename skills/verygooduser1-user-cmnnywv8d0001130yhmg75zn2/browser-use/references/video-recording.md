# Video Recording

Capture browser automation as video for debugging, documentation, or verification.

**⚠️ IMPORTANT**: All examples MUST use `--session` flag (Rule 1).

**Related**: [commands.md](commands.md) for full command reference, [SKILL.md](../SKILL.md) for quick start.

## Basic Recording

```bash
SESSION="record-$(date +%s)-$RANDOM"

# Start recording
agent-browser --session "$SESSION" record start ./demo.webm

# Perform actions
agent-browser --session "$SESSION" open https://example.com
agent-browser --session "$SESSION" snapshot -i
agent-browser --session "$SESSION" click @e1
agent-browser --session "$SESSION" fill @e2 "test input"

# Stop and save
agent-browser --session "$SESSION" record stop

# Close browser when done
agent-browser --session "$SESSION" close
```

## Recording Commands

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# Start recording to file
agent-browser --session "$SESSION" record start ./output.webm

# Stop current recording
agent-browser --session "$SESSION" record stop

# Restart with new file (stops current + starts new)
agent-browser --session "$SESSION" record restart ./take2.webm

# Close browser when done
agent-browser --session "$SESSION" close
```

## Use Cases

### Debugging Failed Automation

```bash
#!/bin/bash
SESSION="debug-$(date +%s)-$RANDOM"

agent-browser --session "$SESSION" record start ./debug-$(date +%Y%m%d-%H%M%S).webm

# Run your automation
agent-browser --session "$SESSION" open https://app.example.com
agent-browser --session "$SESSION" snapshot -i
agent-browser --session "$SESSION" click @e1 || {
    echo "Click failed - check recording"
    agent-browser --session "$SESSION" record stop
    exit 1
}

agent-browser --session "$SESSION" record stop

# Close browser when done
agent-browser --session "$SESSION" close
```

### Documentation Generation

```bash
#!/bin/bash
SESSION="docs-$(date +%s)-$RANDOM"

agent-browser --session "$SESSION" record start ./docs/how-to-login.webm

agent-browser --session "$SESSION" open https://app.example.com/login
agent-browser --session "$SESSION" wait 1000  # Pause for visibility

agent-browser --session "$SESSION" snapshot -i
agent-browser --session "$SESSION" fill @e1 "demo@example.com"
agent-browser --session "$SESSION" wait 500

agent-browser --session "$SESSION" fill @e2 "password"
agent-browser --session "$SESSION" wait 500

agent-browser --session "$SESSION" click @e3
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" wait 1000  # Show result

agent-browser --session "$SESSION" record stop

# Close browser when done
agent-browser --session "$SESSION" close
```

## Best Practices

### 1. Add Pauses for Clarity

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# Slow down for human viewing
agent-browser --session "$SESSION" click @e1
agent-browser --session "$SESSION" wait 500  # Let viewer see result

# Close browser when done
agent-browser --session "$SESSION" close
```

### 2. Use Descriptive Filenames

```bash
# Include context in filename
agent-browser --session "$SESSION" record start ./recordings/login-flow-2024-01-15.webm
agent-browser --session "$SESSION" record start ./recordings/checkout-test-run-42.webm

# Close browser when done
agent-browser --session "$SESSION" close
```

### 3. Handle Recording in Error Cases

```bash
#!/bin/bash
set -e

SESSION="agent-$(date +%s)-$RANDOM"

agent-browser --session "$SESSION" record start ./automation.webm
# ... automation steps ...

# Close browser when done
agent-browser --session "$SESSION" close
```

### 4. Combine with Screenshots

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# Record video AND capture key frames
agent-browser --session "$SESSION" record start ./flow.webm

agent-browser --session "$SESSION" open https://example.com
agent-browser --session "$SESSION" screenshot ./screenshots/step1-homepage.png

agent-browser --session "$SESSION" click @e1
agent-browser --session "$SESSION" screenshot ./screenshots/step2-after-click.png

agent-browser --session "$SESSION" record stop

# Close browser when done
agent-browser --session "$SESSION" close
```

## Output Format

- Default format: WebM (VP8/VP9 codec)
- Compatible with all modern browsers and video players
- Compressed but high quality

## Limitations

- Recording adds slight overhead to automation
- Large recordings can consume significant disk space
- Some headless environments may have codec limitations
