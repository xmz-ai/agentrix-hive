# Proxy Support

Proxy configuration for geo-testing, rate limiting avoidance, and corporate environments.

**⚠️ IMPORTANT**: All examples MUST use `--session` flag (Rule 1).

**Related**: [commands.md](commands.md) for global options, [SKILL.md](../SKILL.md) for quick start.

## Basic Proxy Configuration

Set proxy via environment variable before starting:

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# HTTP proxy
export HTTP_PROXY="http://proxy.example.com:8080"
agent-browser --session "$SESSION" open https://example.com

# HTTPS proxy
export HTTPS_PROXY="https://proxy.example.com:8080"
agent-browser --session "$SESSION" open https://example.com

# Both
export HTTP_PROXY="http://proxy.example.com:8080"
export HTTPS_PROXY="http://proxy.example.com:8080"
agent-browser --session "$SESSION" open https://example.com

# Close browser when done
agent-browser --session "$SESSION" close
```

## Authenticated Proxy

For proxies requiring authentication:

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# Include credentials in URL
export HTTP_PROXY="http://username:password@proxy.example.com:8080"
agent-browser --session "$SESSION" open https://example.com

# Close browser when done
agent-browser --session "$SESSION" close
```

## SOCKS Proxy

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# SOCKS5 proxy
export ALL_PROXY="socks5://proxy.example.com:1080"
agent-browser --session "$SESSION" open https://example.com

# SOCKS5 with auth
export ALL_PROXY="socks5://user:pass@proxy.example.com:1080"
agent-browser --session "$SESSION" open https://example.com

# Close browser when done
agent-browser --session "$SESSION" close
```

## Proxy Bypass

Skip proxy for specific domains:

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# Bypass proxy for local addresses
export NO_PROXY="localhost,127.0.0.1,.internal.company.com"
agent-browser --session "$SESSION" open https://internal.company.com  # Direct
agent-browser --session "$SESSION" open https://external.com          # Via proxy

# Close browser when done
agent-browser --session "$SESSION" close
```

## Common Use Cases

### Geo-Location Testing

```bash
#!/bin/bash
# Test site from different regions using geo-located proxies

PROXIES=(
    "http://us-proxy.example.com:8080"
    "http://eu-proxy.example.com:8080"
    "http://asia-proxy.example.com:8080"
)

for proxy in "${PROXIES[@]}"; do
    export HTTP_PROXY="$proxy"
    export HTTPS_PROXY="$proxy"

    region=$(echo "$proxy" | grep -oP '^\w+-\w+')
    echo "Testing from: $region"

    SESSION="${region}-$(date +%s)-$RANDOM"
    agent-browser --session "$SESSION" open https://example.com
    agent-browser --session "$SESSION" screenshot "./screenshots/$region.png"
    agent-browser --session "$SESSION" close
done
```

### Rotating Proxies for Scraping

```bash
#!/bin/bash
# Rotate through proxy list to avoid rate limiting

PROXY_LIST=(
    "http://proxy1.example.com:8080"
    "http://proxy2.example.com:8080"
    "http://proxy3.example.com:8080"
)

URLS=(
    "https://site.com/page1"
    "https://site.com/page2"
    "https://site.com/page3"
)

for i in "${!URLS[@]}"; do
    proxy_index=$((i % ${#PROXY_LIST[@]}))
    export HTTP_PROXY="${PROXY_LIST[$proxy_index]}"
    export HTTPS_PROXY="${PROXY_LIST[$proxy_index]}"

    SESSION="scrape-$i-$(date +%s)-$RANDOM"
    agent-browser --session "$SESSION" open "${URLS[$i]}"
    agent-browser --session "$SESSION" get text body > "output-$i.txt"
    agent-browser --session "$SESSION" close

    sleep 1  # Polite delay
done
```

### Corporate Network Access

```bash
#!/bin/bash
# Access internal sites via corporate proxy

export HTTP_PROXY="http://corpproxy.company.com:8080"
export HTTPS_PROXY="http://corpproxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.company.com"

SESSION="corp-$(date +%s)-$RANDOM"

# External sites go through proxy
agent-browser --session "$SESSION" open https://external-vendor.com

# Internal sites bypass proxy
agent-browser --session "$SESSION" open https://intranet.company.com

# Close browser when done
agent-browser --session "$SESSION" close
```

## Verifying Proxy Connection

```bash
SESSION="verify-$(date +%s)-$RANDOM"

# Check your apparent IP
agent-browser --session "$SESSION" open https://httpbin.org/ip
agent-browser --session "$SESSION" get text body
# Should show proxy's IP, not your real IP

agent-browser --session "$SESSION" close
```

## Troubleshooting

### Proxy Connection Failed

```bash
# Test proxy connectivity first
curl -x http://proxy.example.com:8080 https://httpbin.org/ip

# Check if proxy requires auth
export HTTP_PROXY="http://user:pass@proxy.example.com:8080"
```

### SSL/TLS Errors Through Proxy

Some proxies perform SSL inspection. If you encounter certificate errors:

```bash
SESSION="agent-$(date +%s)-$RANDOM"

# For testing only - not recommended for production
agent-browser --session "$SESSION" open https://example.com --ignore-https-errors

# Close browser when done
agent-browser --session "$SESSION" close
```

### Slow Performance

```bash
# Use proxy only when necessary
export NO_PROXY="*.cdn.com,*.static.com"  # Direct CDN access
```

## Best Practices

1. **Use environment variables** - Don't hardcode proxy credentials
2. **Set NO_PROXY appropriately** - Avoid routing local traffic through proxy
3. **Test proxy before automation** - Verify connectivity with simple requests
4. **Handle proxy failures gracefully** - Implement retry logic for unstable proxies
5. **Rotate proxies for large scraping jobs** - Distribute load and avoid bans
