# frozen_string_literal: true

require_relative '../lib/z/ai'
require 'logger'

puts "Configuration and Customization Examples"
puts "=" * 50

# Example 1: Basic Configuration
puts "\n1. Basic Client Configuration"
puts "-" * 30

basic_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here',
  base_url: 'https://api.z.ai/api/paas/v4/',
  timeout: 30
)

puts "Basic client created with:"
puts "  API Key: #{basic_client.config.api_key[0..10]}..."
puts "  Base URL: #{basic_client.config.base_url}"
puts "  Timeout: #{basic_client.config.timeout}s"

# Example 2: Environment-based Configuration
puts "\n2. Environment Variable Configuration"
puts "-" * 30

# Set environment variables
ENV['ZAI_API_KEY'] ||= 'test-api-key'
ENV['ZAI_BASE_URL'] ||= 'https://api.z.ai/api/paas/v4/'
ENV['ZAI_LOG_LEVEL'] = 'debug'

env_client = Z::AI::Client.new

puts "Environment-based configuration:"
puts "  API Key from ENV: #{env_client.config.api_key[0..10]}..."
puts "  Base URL from ENV: #{env_client.config.base_url}"
puts "  Log Level from ENV: #{env_client.config.log_level}"

# Example 3: Global Configuration
puts "\n3. Global Configuration"
puts "-" * 30

Z::AI.configure do |config|
  config.api_key = ENV['ZAI_API_KEY'] || 'global-api-key'
  config.base_url = 'https://api.z.ai/api/paas/v4/'
  config.timeout = 45
  config.max_retries = 5
  config.retry_delay = 2
  config.logger = Logger.new($stdout)
  config.log_level = :info
  config.source_channel = 'my-app'
  config.disable_token_cache = false
  config.custom_headers = {
    'X-Custom-Header' => 'custom-value',
    'X-App-Version' => '1.0.0'
  }
end

puts "Global configuration set:"
puts "  Timeout: #{Z::AI.configuration.timeout}s"
puts "  Max Retries: #{Z::AI.configuration.max_retries}"
puts "  Source Channel: #{Z::AI.configuration.source_channel}"
puts "  Custom Headers: #{Z::AI.configuration.custom_headers.keys.join(', ')}"

# Example 4: Per-Instance Configuration Override
puts "\n4. Instance-specific Configuration Override"
puts "-" * 30

# Create client with different settings than global
override_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'override-api-key',
  timeout: 60,
  max_retries: 10,
  source_channel: 'special-client'
)

puts "Override client configuration:"
puts "  Timeout: #{override_client.config.timeout}s (global: #{Z::AI.configuration.timeout}s)"
puts "  Max Retries: #{override_client.config.max_retries} (global: #{Z::AI.configuration.max_retries})"
puts "  Source: #{override_client.config.source_channel} (global: #{Z::AI.configuration.source_channel})"

# Example 5: Custom Logger Configuration
puts "\n5. Custom Logger Configuration"
puts "-" * 30

custom_logger = Logger.new('tmp/z_ai.log')
custom_logger.level = Logger::DEBUG
custom_logger.formatter = proc do |severity, datetime, progname, msg|
  "[#{datetime.strftime('%Y-%m-%d %H:%M:%S.%L')}] #{severity.ljust(5)} #{msg}\n"
end

logging_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here',
  logger: custom_logger,
  log_level: :debug
)

puts "Custom logger configured"
puts "  Log file: tmp/z_ai.log"
puts "  Log level: #{logging_client.config.log_level}"

# Example 6: Proxy Configuration
puts "\n6. Proxy Configuration"
puts "-" * 30

proxy_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here',
  proxy_url: 'http://proxy.example.com:8080'
)

puts "Proxy configuration:"
puts "  Proxy URL: #{proxy_client.config.proxy_url}"

# Example 7: Authentication Options
puts "\n7. Authentication Configuration"
puts "-" * 30

# Direct API key (no JWT)
direct_auth_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here',
  disable_token_cache: true
)

puts "Direct authentication:"
puts "  Token cache disabled: #{direct_auth_client.config.disable_token_cache}"

# JWT with caching
jwt_auth_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key.id.secret',
  disable_token_cache: false
)

puts "JWT authentication:"
puts "  Token cache enabled: #{!jwt_auth_client.config.disable_token_cache}"

# Example 8: Timeout Configuration
puts "\n8. Detailed Timeout Configuration"
puts "-" * 30

timeout_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here',
  timeout: 60,           # Overall timeout
  open_timeout: 10,      # Connection timeout
  read_timeout: 30,      # Read timeout
  write_timeout: 30      # Write timeout
)

puts "Timeout configuration:"
puts "  Overall: #{timeout_client.config.timeout}s"
puts "  Open: #{timeout_client.config.open_timeout}s"
puts "  Read: #{timeout_client.config.read_timeout}s"
puts "  Write: #{timeout_client.config.write_timeout}s"

# Example 9: Retry Configuration
puts "\n9. Retry Configuration"
puts "-" * 30

retry_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here',
  max_retries: 5,
  retry_delay: 2
)

puts "Retry configuration:"
puts "  Max retries: #{retry_client.config.max_retries}"
puts "  Retry delay: #{retry_client.config.retry_delay}s"
puts "  Max wait time: #{retry_client.config.max_retries * retry_client.config.retry_delay}s"

# Example 10: Configuration Validation
puts "\n10. Configuration Validation"
puts "-" * 30

begin
  invalid_client = Z::AI::Client.new(
    api_key: nil,  # This should fail validation
    base_url: nil
  )
rescue Z::AI::ConfigurationError => e
  puts "Configuration validation caught error:"
  puts "  #{e.message}"
end

begin
  valid_client = Z::AI::Client.new(
    api_key: ENV['ZAI_API_KEY'] || 'valid-api-key',
    base_url: 'https://api.z.ai/api/paas/v4/'
  )
  puts "Valid configuration accepted"
  puts "  API Key: #{valid_client.config.api_key[0..10]}..."
  puts "  Base URL: #{valid_client.config.base_url}"
rescue => e
  puts "Unexpected error: #{e.message}"
end

# Example 11: Configuration from Hash
puts "\n11. Configuration from Hash"
puts "-" * 30

config_hash = {
  api_key: ENV['ZAI_API_KEY'] || 'hash-api-key',
  base_url: 'https://api.z.ai/api/paas/v4/',
  timeout: 40,
  max_retries: 4,
  source_channel: 'hash-config-app'
}

hash_client = Z::AI::Client.new(**config_hash)

puts "Hash-based configuration:"
puts "  Timeout: #{hash_client.config.timeout}s"
puts "  Max Retries: #{hash_client.config.max_retries}"
puts "  Source: #{hash_client.config.source_channel}"

# Example 12: Configuration Export and Import
puts "\n12. Configuration Export/Import"
puts "-" * 30

# Export configuration to hash
config_export = hash_client.config.to_h

puts "Exported configuration:"
puts JSON.pretty_generate(config_export.transform_values { |v| v.is_a?(String) && v.length > 20 ? "#{v[0..20]}..." : v })

# Import configuration
import_client = Z::AI::Client.new(**config_export)

puts "\nImported client created successfully"
puts "  Configuration matches: #{import_client.config.timeout == hash_client.config.timeout}"

# Example 13: Multi-environment Configuration
puts "\n13. Multi-environment Configuration"
puts "-" * 30

environments = {
  development: {
    api_key: ENV['ZAI_API_KEY'] || 'dev-key',
    base_url: 'https://api.z.ai/api/paas/v4/',
    timeout: 60,
    log_level: :debug
  },
  production: {
    api_key: ENV['ZAI_API_KEY'] || 'prod-key',
    base_url: 'https://api.z.ai/api/paas/v4/',
    timeout: 30,
    log_level: :warn
  },
  test: {
    api_key: 'test-key',
    base_url: 'https://test.z.ai/api/paas/v4/',
    timeout: 5,
    log_level: :error
  }
}

current_env = :development
env_config = environments[current_env]

env_specific_client = Z::AI::Client.new(**env_config)

puts "Environment-specific configuration (#{current_env}):"
puts "  Timeout: #{env_specific_client.config.timeout}s"
puts "  Log Level: #{env_specific_client.config.log_level}"
puts "  Base URL: #{env_specific_client.config.base_url}"

# Example 14: Dynamic Configuration Updates
puts "\n14. Dynamic Configuration Updates"
puts "-" * 30

dynamic_client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here',
  timeout: 30
)

puts "Initial timeout: #{dynamic_client.config.timeout}s"

# Update configuration
dynamic_client.config.timeout = 60
dynamic_client.config.max_retries = 5

puts "Updated timeout: #{dynamic_client.config.timeout}s"
puts "Updated max retries: #{dynamic_client.config.max_retries}"

# Example 15: Configuration Inheritance
puts "\n15. Configuration Inheritance Pattern"
puts "-" * 30

class CustomZaiClient < Z::AI::Client
  DEFAULT_CONFIG = {
    timeout: 45,
    max_retries: 4,
    source_channel: 'custom-client',
    custom_headers: {
      'X-Client-Type' => 'custom'
    }
  }
  
  def initialize(api_key:, **options)
    super(api_key: api_key, **DEFAULT_CONFIG.merge(options))
  end
  
  def custom_method
    "Custom client with timeout: #{config.timeout}s"
  end
end

custom_client = CustomZaiClient.new(
  api_key: ENV['ZAI_API_KEY'] || 'custom-api-key'
)

puts "Custom client created:"
puts "  #{custom_client.custom_method}"
puts "  Source: #{custom_client.config.source_channel}"
puts "  Custom headers: #{custom_client.config.custom_headers.keys.join(', ')}"

puts "\nConfiguration Examples Complete!"
puts "\nKey configuration patterns demonstrated:"
puts "1. Basic client configuration"
puts "2. Environment variable integration"
puts "3. Global configuration"
puts "4. Instance-specific overrides"
puts "5. Custom logger setup"
puts "6. Proxy configuration"
puts "7. Authentication options (direct vs JWT)"
puts "8. Detailed timeout settings"
puts "9. Retry configuration"
puts "10. Configuration validation"
puts "11. Hash-based configuration"
puts "12. Export/import functionality"
puts "13. Multi-environment setup"
puts "14. Dynamic updates"
puts "15. Custom client inheritance"