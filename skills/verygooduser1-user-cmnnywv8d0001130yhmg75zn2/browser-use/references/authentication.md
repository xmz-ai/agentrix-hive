# Authentication Patterns

Login flows, session persistence, OAuth, 2FA, and authenticated browsing.

**⚠️ IMPORTANT**: All examples MUST use `--session` flag (Rule 1).

**Related**: [commands.md](commands.md) for state persistence commands, [SKILL.md](../SKILL.md) for quick start.

## Basic Login Flow

```bash
SESSION="auth-$(date +%s)-$RANDOM"

# Navigate to login page
agent-browser --session "$SESSION" open https://app.example.com/login
agent-browser --session "$SESSION" wait --load networkidle

# Get form elements
agent-browser --session "$SESSION" snapshot -i
# Output: @e1 [input type="email"], @e2 [input type="password"], @e3 [button] "Sign In"

# Fill credentials
agent-browser --session "$SESSION" fill @e1 "user@example.com"
agent-browser --session "$SESSION" fill @e2 "password123"

# Submit
agent-browser --session "$SESSION" click @e3
agent-browser --session "$SESSION" wait --load networkidle

# Verify login succeeded
agent-browser --session "$SESSION" get url  # Should be dashboard, not login

# Close browser when done
agent-browser --session "$SESSION" close
```

## Saving Authentication State

After logging in, save state for reuse:

```bash
SESSION="auth-$(date +%s)-$RANDOM"

# Login first (see above)
agent-browser --session "$SESSION" open https://app.example.com/login
agent-browser --session "$SESSION" snapshot -i
agent-browser --session "$SESSION" fill @e1 "user@example.com"
agent-browser --session "$SESSION" fill @e2 "password123"
agent-browser --session "$SESSION" click @e3
agent-browser --session "$SESSION" wait --url "**/dashboard"

# Save authenticated state
agent-browser --session "$SESSION" state save ./auth-state.json

# Close browser when done
agent-browser --session "$SESSION" close
```

## Restoring Authentication

Skip login by loading saved state:

```bash
SESSION="auth-$(date +%s)-$RANDOM"

# Load saved auth state
agent-browser --session "$SESSION" state load ./auth-state.json

# Navigate directly to protected page
agent-browser --session "$SESSION" open https://app.example.com/dashboard

# Verify authenticated
agent-browser --session "$SESSION" snapshot -i

# Close browser when done
agent-browser --session "$SESSION" close
```

## OAuth / SSO Flows

For OAuth redirects:

```bash
SESSION="oauth-$(date +%s)-$RANDOM"

# Start OAuth flow
agent-browser --session "$SESSION" open https://app.example.com/auth/google

# Handle redirects automatically
agent-browser --session "$SESSION" wait --url "**/accounts.google.com**"
agent-browser --session "$SESSION" snapshot -i

# Fill Google credentials
agent-browser --session "$SESSION" fill @e1 "user@gmail.com"
agent-browser --session "$SESSION" click @e2  # Next button
agent-browser --session "$SESSION" wait 2000
agent-browser --session "$SESSION" snapshot -i
agent-browser --session "$SESSION" fill @e3 "password"
agent-browser --session "$SESSION" click @e4  # Sign in

# Wait for redirect back
agent-browser --session "$SESSION" wait --url "**/app.example.com**"
agent-browser --session "$SESSION" state save ./oauth-state.json

# Close browser when done
agent-browser --session "$SESSION" close
```

## Two-Factor Authentication

Handle 2FA with manual intervention:

```bash
SESSION="2fa-$(date +%s)-$RANDOM"

# Login with credentials
agent-browser --session "$SESSION" --headed open https://app.example.com/login
agent-browser --session "$SESSION" snapshot -i
agent-browser --session "$SESSION" fill @e1 "user@example.com"
agent-browser --session "$SESSION" fill @e2 "password123"
agent-browser --session "$SESSION" click @e3

# Wait for user to complete 2FA manually
echo "Complete 2FA in the browser window..."
agent-browser --session "$SESSION" wait --url "**/dashboard" --timeout 120000

# Save state after 2FA
agent-browser --session "$SESSION" state save ./2fa-state.json

# Close browser when done
agent-browser --session "$SESSION" close
```

## Login Once, Reuse Pattern

```bash
#!/bin/bash
SESSION="reuse-$(date +%s)-$RANDOM"
STATE_FILE="./auth-state.json"

# Check if we have saved state
if [ -f "$STATE_FILE" ]; then
    agent-browser --session "$SESSION" state load "$STATE_FILE"
    agent-browser --session "$SESSION" open https://app.example.com/dashboard
    agent-browser --session "$SESSION" wait --load networkidle

    # Verify still logged in
    URL=$(agent-browser --session "$SESSION" get url)
    if [[ "$URL" == *"/login"* ]]; then
        echo "Session expired, re-authenticating..."
        rm "$STATE_FILE"
        # Fall through to login below
    else
        echo "Session restored successfully"
        agent-browser --session "$SESSION" snapshot -i
        exit 0
    fi
fi

# Perform fresh login
echo "Logging in..."
agent-browser --session "$SESSION" open https://app.example.com/login
agent-browser --session "$SESSION" wait --load networkidle
agent-browser --session "$SESSION" snapshot -i

agent-browser --session "$SESSION" fill @e1 "$APP_USERNAME"
agent-browser --session "$SESSION" fill @e2 "$APP_PASSWORD"
agent-browser --session "$SESSION" click @e3
agent-browser --session "$SESSION" wait --url "**/dashboard"

# Save for future use
echo "Saving session state..."
agent-browser --session "$SESSION" state save "$STATE_FILE"

agent-browser --session "$SESSION" snapshot -i

# Close browser when done
agent-browser --session "$SESSION" close
```

## HTTP Basic Auth

For sites using HTTP Basic Authentication:

```bash
SESSION="basic-$(date +%s)-$RANDOM"

# Set credentials before navigation
agent-browser --session "$SESSION" set credentials username password

# Navigate to protected resource
agent-browser --session "$SESSION" open https://protected.example.com/api

# Close browser when done
agent-browser --session "$SESSION" close
```

## Security Best Practices

1. **Never commit state files** - They contain session tokens
   ```bash
   echo "*.auth-state.json" >> .gitignore
   ```

2. **Use environment variables for credentials**
   ```bash
   agent-browser --session "$SESSION" fill @e1 "$APP_USERNAME"
   agent-browser --session "$SESSION" fill @e2 "$APP_PASSWORD"
   ```

3. **Clean up after automation**
   ```bash
   agent-browser --session "$SESSION" cookies clear
   rm -f ./auth-state.json
   ```

4. **Use short-lived sessions for CI/CD**
   ```bash
   # Don't persist state in CI
   agent-browser --session "$SESSION" open https://app.example.com/login
   # ... login and perform actions ...
   agent-browser --session "$SESSION" close  # Session ends, nothing persisted
   ```
