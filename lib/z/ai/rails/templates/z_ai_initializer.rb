# frozen_string_literal: true

# Z.ai Ruby SDK Rails Initializer
# =================================

require 'z/ai'

# Configure Z.ai SDK
Z::AI.configure do |config|
  # API key (required)
  config.api_key = ENV['ZAI_API_KEY']
  
  # Base URL (optional, defaults to Z.ai API)
  # config.base_url = 'https://api.z.ai/api/paas/v4/'
  
  # Request timeout in seconds
  config.timeout = (ENV['ZAI_TIMEOUT'] || 30).to_i
  
  # Maximum retry attempts for failed requests
  config.max_retries = (ENV['ZAI_MAX_RETRIES'] || 3).to_i
  
  # Use Rails logger
  config.logger = Rails.logger
  
  # Log level based on environment
  config.log_level = Rails.env.production? ? :info : :debug
  
  # Source channel identifier
  config.source_channel = 'ruby-sdk-rails'
  
  # Disable JWT token caching in development for easier testing
  if Rails.env.development? || Rails.env.test?
    config.disable_token_cache = true
  end
end

# Optional: Define a global client instance
# $zai_client = Z::AI::Client.new

# Optional: Add custom error handling
# ActiveSupport::Notifications.subscribe('error.z_ai') do |name, start, finish, id, payload|
#   Rails.logger.error("[Z::AI] Error: #{payload[:error].message}")
# end

# Optional: Add instrumentation
# ActiveSupport::Notifications.subscribe('request.z_ai') do |name, start, finish, id, payload|
#   duration = (finish - start) * 1000
#   Rails.logger.info("[Z::AI] Request to #{payload[:endpoint]} took #{duration}ms")
# end
