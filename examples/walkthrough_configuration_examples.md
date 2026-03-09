# Configuration Examples Walkthrough

Complete guide to configuring the Z.ai Ruby SDK.

## Overview

Learn how to configure the SDK for different environments and use cases.

## Configuration Methods

1. **Direct Configuration** - Pass options to client constructor
2. **Environment Variables** - Use `ZAI_API_KEY`, `ZAI_BASE_URL`, etc.
3. **Global Configuration** - Use `Z::AI.configure` block
4. **Instance Overrides** - Override global settings per client
5. **Custom Clients** - Inherit from base client class

## Key Settings

- `api_key` - Authentication key
- `base_url` - API endpoint
- `timeout` - Request timeout
- `max_retries` - Retry attempts
- `logger` - Logging configuration
- `proxy_url` - Proxy server

## Best Practices

- Use environment variables for sensitive data
- Implement environment-specific configs
- Enable logging in development
- Use appropriate timeout values
- Configure retry logic carefully
