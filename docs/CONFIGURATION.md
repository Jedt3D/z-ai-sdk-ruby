# Configuration Guide

Complete guide to configuring the Z.ai Ruby SDK for your application.

## Table of Contents

1. [Basic Configuration](#basic-configuration)
2. [Environment Variables](#environment-variables)
3. [Global vs Instance Configuration](#global-vs-instance-configuration)
4. [Advanced Options](#advanced-options)
5. [Rails Integration](#rails-integration)
6. [Best Practices](#best-practices)

## Basic Configuration

### Simple Setup

```ruby
require 'z/ai'

Z::AI.configure do |config|
  config.api_key = 'your-api-key-here'
end

# Use globally configured client
response = Z::AI.chat.completions.create(
  model: 'glm-5',
  messages: [{ role: 'user', content: 'Hello!' }]
)
```

### Client Instance

```ruby
client = Z::AI::Client.new(
  api_key: 'your-api-key-here',
  timeout: 60
)

response = client.chat.completions.create(...)
```

## Environment Variables

The SDK automatically reads configuration from environment variables.

### Available Variables

```bash
export ZAI_API_KEY="your-api-key-here"
export ZAI_BASE_URL="https://api.z.ai/api/paas/v4/"
export ZAI_LOG_LEVEL="debug"
export ZAI_PROXY_URL="http://proxy.example.com:8080"
```

### Using Environment Variables

```ruby
# SDK automatically uses environment variables
client = Z::AI::Client.new

# No need to explicitly set api_key if ZAI_API_KEY is set
```

## Global vs Instance Configuration

### Global Configuration

Use for application-wide settings:

```ruby
# Set once in initializer
Z::AI.configure do |config|
  config.api_key = ENV['ZAI_API_KEY']
  config.timeout = 30
  config.max_retries = 3
end

# Used everywhere
Z::AI.chat.completions.create(...)
```

### Instance Configuration

Override global settings for specific clients:

```ruby
# Global config
Z::AI.configure do |config|
  config.api_key = ENV['ZAI_API_KEY']
  config.timeout = 30
end

# Override for specific use case
long_running_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'],
  timeout: 300  # 5 minutes for long operations
)

# Another override
fast_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'],
  timeout: 5,
  max_retries: 1
)
```

## Advanced Options

### All Configuration Options

```ruby
Z::AI.configure do |config|
  # Required
  config.api_key = 'your-api-key'
  
  # Connection
  config.base_url = 'https://api.z.ai/api/paas/v4/'
  
  # Timeouts (in seconds)
  config.timeout = 30           # Overall timeout
  config.open_timeout = 10       # Connection open timeout
  config.read_timeout = 30       # Read timeout
  config.write_timeout = 30      # Write timeout
  
  # Retry behavior
  config.max_retries = 3         # Maximum retry attempts
  config.retry_delay = 1         # Delay between retries (seconds)
  
  # Logging
  config.logger = Logger.new(STDOUT)
  config.log_level = :info       # :debug, :info, :warn, :error
  
  # Authentication
  config.disable_token_cache = false  # Disable JWT caching
  config.source_channel = 'my-app'    # Custom source identifier
  
  # Proxy
  config.proxy_url = 'http://proxy.example.com:8080'
  
  # Custom headers
  config.custom_headers = {
    'X-Custom-Header' => 'value',
    'X-App-Version' => '1.0.0'
  }
end
```

### Timeout Configuration

```ruby
client = Z::AI::Client.new(
  timeout: 60,        # Overall request timeout
  open_timeout: 10,   # Connection establishment timeout
  read_timeout: 30,   # Read operation timeout
  write_timeout: 30   # Write operation timeout
)
```

### Retry Configuration

```ruby
client = Z::AI::Client.new(
  max_retries: 5,     # Retry up to 5 times
  retry_delay: 2      # Wait 2 seconds between retries
)
```

### Logging Configuration

```ruby
require 'logger'

client = Z::AI::Client.new(
  logger: Logger.new('tmp/z_ai.log'),
  log_level: :debug
)

# Log levels: :debug, :info, :warn, :error
```

### Proxy Configuration

```ruby
# HTTP proxy
client = Z::AI::Client.new(
  proxy_url: 'http://proxy.example.com:8080'
)

# HTTPS proxy
client = Z::AI::Client.new(
  proxy_url: 'https://proxy.example.com:8443'
)

# With authentication
client = Z::AI::Client.new(
  proxy_url: 'http://user:password@proxy.example.com:8080'
)
```

### Custom Headers

```ruby
client = Z::AI::Client.new(
  custom_headers: {
    'X-Request-ID' => SecureRandom.uuid,
    'X-App-Version' => '1.0.0',
    'X-Environment' => 'production'
  }
)
```

## Rails Integration

### Initializer

Create `config/initializers/z_ai.rb`:

```ruby
require 'z/ai'

Z::AI.configure do |config|
  config.api_key = ENV['ZAI_API_KEY']
  config.timeout = (ENV['ZAI_TIMEOUT'] || 30).to_i
  config.max_retries = (ENV['ZAI_MAX_RETRIES'] || 3).to_i
  
  # Use Rails logger
  config.logger = Rails.logger
  config.log_level = Rails.env.production? ? :info : :debug
  
  # Environment-specific settings
  config.source_channel = "rails-app-#{Rails.env}"
  
  # Disable caching in development
  if Rails.env.development? || Rails.env.test?
    config.disable_token_cache = true
  end
end
```

### Environment Configuration

Create `config/z_ai.yml`:

```yaml
development:
  api_key: <%= ENV['ZAI_API_KEY'] %>
  timeout: 60
  max_retries: 3
  log_level: debug

test:
  api_key: <%= ENV['ZAI_API_KEY'] || 'test_key' %>
  timeout: 30
  max_retries: 1
  log_level: error

production:
  api_key: <%= ENV['ZAI_API_KEY'] %>
  timeout: 30
  max_retries: 5
  log_level: warn
```

### Per-Environment Client

```ruby
# Different clients for different environments
class ApplicationController < ActionController::Base
  private
  
  def ai_client
    @ai_client ||= if Rails.env.production?
      Z::AI::Client.new(
        api_key: ENV['ZAI_API_KEY_PRODUCTION'],
        timeout: 30,
        max_retries: 5
      )
    else
      Z::AI::Client.new(
        api_key: ENV['ZAI_API_KEY_DEVELOPMENT'],
        timeout: 60,
        max_retries: 3
      )
    end
  end
end
```

## Best Practices

### 1. Use Environment Variables

```ruby
# Good
config.api_key = ENV['ZAI_API_KEY']

# Bad - don't hardcode
config.api_key = 'sk-1234567890abcdef'
```

### 2. Configure Logging

```ruby
# Development
config.logger = Logger.new(STDOUT)
config.log_level = :debug

# Production
config.logger = Rails.logger
config.log_level = :info
```

### 3. Set Appropriate Timeouts

```ruby
# Quick operations
config.timeout = 10

# Long operations (batch processing)
config.timeout = 300

# Default for most cases
config.timeout = 30
```

### 4. Configure Retries Wisely

```ruby
# Critical operations - more retries
config.max_retries = 5
config.retry_delay = 2

# Non-critical - fewer retries
config.max_retries = 2
config.retry_delay = 1

# Background jobs - aggressive retries
config.max_retries = 10
config.retry_delay = 5
```

### 5. Use Source Channel

```ruby
config.source_channel = "my-app/#{Rails.env}/#{APP_VERSION}"
```

## Configuration Validation

The SDK validates configuration on client creation:

```ruby
begin
  client = Z::AI::Client.new  # Missing api_key
rescue Z::AI::ConfigurationError => e
  puts "Configuration error: #{e.message}"
  # => "API key is required"
end
```

## Configuration Inheritance

Create custom client classes:

```ruby
class LongRunningClient < Z::AI::Client
  def initialize(api_key:)
    super(
      api_key: api_key,
      timeout: 300,
      max_retries: 10
    )
  end
end

class FastClient < Z::AI::Client
  def initialize(api_key:)
    super(
      api_key: api_key,
      timeout: 5,
      max_retries: 1
    )
  end
end
```

## Dynamic Configuration

Update configuration at runtime:

```ruby
# Get current config
config = Z::AI.configuration

# Update values
config.timeout = 60
config.max_retries = 5

# Changes apply to new client instances
client = Z::AI::Client.new(config)
```

## See Also

- [API Reference](API.md)
- [Error Handling](ERROR_HANDLING.md)
- [Examples](../examples/)
