# Z.ai Ruby SDK Implementation Plan

## Ruby Version Requirements

This SDK supports:
- **Ruby >= 3.2.8** (updated from Ruby >= 3.0.0)
- **JRuby >= 10.0.4.0** (updated from JRuby >= 9.4.0.0)

## Phase 1: Core Infrastructure

### 1.1 Project Setup
```ruby
# Gemfile structure
source "https://rubygems.org"
ruby ">= 3.2.8"
gemspec

# Dependencies to evaluate:
gem "httparty", "~> 0.21"  # HTTP client
gem "jwt", "~> 2.7"        # JWT handling
gem "dry-struct", "~> 1.6" # Type-safe models
gem "dry-validation", "~> 1.9" # Input validation

# JRuby-specific dependencies
gem "concurrent-ruby", "~> 1.2", platforms: :jruby if RUBY_ENGINE == 'jruby'
```

### 1.2 Base Client Implementation
```ruby
# lib/zai/client.rb
module Zai
  class Client
    attr_reader :configuration
    
    def initialize(**options)
      @configuration = Configuration.new(options)
      validate_configuration!
    end
    
    # API resource lazy initialization
    def chat
      @chat ||= API::Chat.new(self)
    end
    
    def embeddings
      @embeddings ||= API::Embeddings.new(self)
    end
    
    # Connection management
    def connection
      @connection ||= HTTPConnection.new(configuration)
    end
    
    private
    
    def validate_configuration!
      # Validate API key presence
      # Validate URL format
      # Validate other required options
    end
  end
end
```

### 1.3 Configuration System
```ruby
# lib/zai/configuration.rb
module Zai
  class Configuration
    attr_accessor :api_key, :base_url, :timeout, :max_retries, 
                  :disable_token_cache, :source_channel
    
    def initialize(options = {})
      apply_defaults!
      apply_options(options)
      apply_env_vars!
    end
    
    def for_overseas?
      base_url&.include?("api.z.ai") || default_overseas_url?
    end
    
    def for_china?
      base_url&.include?("bigmodel.cn") || default_china_url?
    end
    
    private
    
    def apply_defaults!
      @timeout = 30
      @max_retries = 3
      @disable_token_cache = true
      @source_channel = "ruby-sdk"
    end
    
    def apply_options(options)
      options.each { |key, value| send("#{key}=", value) if respond_to?("#{key}=") }
    end
    
    def apply_env_vars!
      @api_key ||= ENV["ZAI_API_KEY"]
      @base_url ||= ENV["ZAI_BASE_URL"]
    end
  end
end
```

## Phase 2: HTTP Layer

### 2.1 HTTP Connection Wrapper
```ruby
# lib/zai/http_connection.rb
module Zai
  class HTTPConnection
    include Retryable
    
    def initialize(configuration)
      @configuration = configuration
      @client = build_http_client
    end
    
    def get(path, params = {})
      request(:get, path, params: params)
    end
    
    def post(path, body = {})
      request(:post, path, body: body)
    end
    
    def stream_post(path, body = {}, &block)
      headers = build_headers
      response = @client.post(path, body: body.to_json, headers: headers, stream_response: true)
      
      response.body.each(&block) if block_given?
      response
    end
    
    private
    
    def build_http_client
      HTTParty.persistent(configuration.base_url) do |http|
        http.timeout configuration.timeout
        http.open_timeout configuration.timeout / 2
        
        http.headers.update(build_headers)
      end
    end
    
    def build_headers
      base_headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
      
      if configuration.for_overseas?
        base_headers["Accept-Language"] = "en-US,en"
      end
      
      auth_headers = if configuration.disable_token_cache
        ApiKeyAuth.new(configuration.api_key, configuration.source_channel).headers
      else
        JwtAuth.new(configuration.api_key).headers
      end
      
      base_headers.merge(auth_headers)
    end
    
    def request(method, path, options = {})
      with_retries(max_retries: configuration.max_retries) do
        response = @client.public_send(method, path, options)
        handle_response(response)
      end
    end
    
    def handle_response(response)
      case response.code
      when 200..299
        parse_response(response)
      when 401
        raise AuthenticationError.new("Authentication failed", status_code: response.code)
      when 429
        raise RateLimitError.new("Rate limit exceeded", status_code: response.code)
      when 500..599
        raise ServerError.new("Server error", status_code: response.code)
      else
        raise APIError.new("API error", status_code: response.code, response_body: response.body)
      end
    end
    
    def parse_response(response)
      JSON.parse(response.body)
    rescue JSON::ParserError
      response.body
    end
  end
end
```

### 2.2 Authentication Modules
```ruby
# lib/zai/auth/api_key_auth.rb
module Zai
  module Auth
    class ApiKeyAuth
      attr_reader :api_key, :source_channel
      
      def initialize(api_key, source_channel = "ruby-sdk")
        @api_key = api_key
        @source_channel = source_channel
      end
      
      def headers
        {
          "Authorization" => "Bearer #{api_key}",
          "x-source-channel" => source_channel
        }
      end
    end
  end
end

# lib/zai/auth/jwt_auth.rb
module Zai
  module Auth
    class JwtAuth
      attr_reader :api_key, :cache, :ttl
      
      def initialize(api_key, cache: nil, ttl: 3600, source_channel: "ruby-sdk")
        @api_key = api_key
        @cache = cache || MemoryCache.new
        @ttl = ttl
        @source_channel = source_channel
      end
      
      def headers
        token = cached_token || generate_token
        {
          "Authorization" => "Bearer #{token}",
          "x-source-channel" => source_channel
        }
      end
      
      private
      
      def cached_token
        cache.get("jwt_token") if cache
      end
      
      def generate_token
        id, secret = api_key.split(".")
        
        payload = {
          api_key: id,
          exp: (Time.now.to_f * 1000).to_i + ttl * 1000,
          timestamp: (Time.now.to_f * 1000).to_i
        }
        
        token = JWT.encode(payload, secret, "HS256", { typ: "JWT", alg: "HS256" })
        cache.set("jwt_token", token, ttl: ttl) if cache
        
        token
      rescue JWT::EncodeError => e
        raise Zai::Error, "Failed to generate JWT token: #{e.message}"
      end
    end
  end
end
```

## Phase 3: API Resources

### 3.1 Base API Resource
```ruby
# lib/zai/api/base.rb
module Zai
  module API
    class Base
      def initialize(client)
        @client = client
      end
      
      protected
      
      attr_reader :client
      
      def connection
        client.connection
      end
      
      def post(endpoint, body = {})
        connection.post(endpoint, body)
      end
      
      def get(endpoint, params = {})
        connection.get(endpoint, params)
      end
      
      def stream(endpoint, body = {}, &block)
        connection.stream_post(endpoint, body, &block)
      end
    end
  end
end
```

### 3.2 Chat API Implementation
```ruby
# lib/zai/api/chat.rb
module Zai
  module API
    class Chat < Base
      def completions(messages:, model: "glm-5", **options)
        request_body = build_completion_request(messages, model, options)
        response = post("/chat/completions", request_body)
        
        Models::ChatCompletionResponse.new(response)
      end
      
      def stream(messages:, model: "glm-5", **options, &block)
        request_body = build_completion_request(messages, model, options.merge(stream: true))
        
        if block_given?
          stream("/chat/completions", request_body) do |chunk|
            yield parse_stream_chunk(chunk)
          end
        else
          # Return enumerator if no block given
          to_enum(:stream, messages: messages, model: model, **options)
        end
      end
      
      private
      
      def build_completion_request(messages, model, options)
        {
          model: model,
          messages: normalize_messages(messages),
          temperature: options[:temperature] || 0.7,
          max_tokens: options[:max_tokens],
          stream: options[:stream] || false,
          **options.except(:temperature, :max_tokens, :stream)
        }
      end
      
      def normalize_messages(messages)
        case messages
        when Array
          messages.map { |msg| Models::ChatMessage.new(msg).to_h }
        when String
          [{ role: "user", content: messages }]
        else
          raise ArgumentError, "Messages must be an array or string"
        end
      end
      
      def parse_stream_chunk(chunk)
        lines = chunk.split("\n").select { |line| line.start_with?("data: ") }
        return nil if lines.empty?
        
        data = lines.last.sub(/^data: /, "")
        return nil if data == "[DONE]"
        
        JSON.parse(data)
      rescue JSON::ParserError
        nil
      end
    end
  end
end
```

## Phase 4: Data Models

### 4.1 Base Model
```ruby
# lib/zai/models/base.rb
module Zai
  module Models
    class Base
      include Dry::Struct
      
      transform_keys(&:to_sym)
    end
  end
end
```

### 4.2 Chat Models
```ruby
# lib/zai/models/chat_message.rb
module Zai
  module Models
    class ChatMessage < Base
      attribute :role, Types::String.enum("system", "user", "assistant")
      attribute :content, Types::String
      attribute :name, Types::String.optional
      
      def to_h
        super.reject { |_, v| v.nil? }
      end
    end
    
    class ChatCompletionResponse < Base
      attribute :id, Types::String
      attribute :object, Types::String.default("chat.completion")
      attribute :created, Types::Integer
      attribute :model, Types::String
      attribute :choices, Types.Array(ChatChoice)
      attribute :usage, Usage.optional
      
      def first_message
        choices.first&.message&.content
      end
    end
    
    class ChatChoice < Base
      attribute :index, Types::Integer
      attribute :message, ChatMessage
      attribute :finish_reason, Types::String
    end
    
    class Usage < Base
      attribute :prompt_tokens, Types::Integer
      attribute :completion_tokens, Types::Integer
      attribute :total_tokens, Types::Integer
    end
  end
end
```

## Phase 5: Error Handling

### 5.1 Retry Mechanism
```ruby
# lib/zai/concerns/retryable.rb
module Zai
  module Retryable
    def with_retries(max_retries: 3, base_delay: 1.0)
      attempts = 0
      
      begin
        yield
      rescue Timeout::Error, ServerError => e
        attempts += 1
        raise if attempts >= max_retries
        
        delay = base_delay * (2 ** (attempts - 1))
        sleep(delay)
        retry
      end
    end
  end
end
```

### 5.2 Error Classes
```ruby
# lib/zai/error.rb
module Zai
  class Error < StandardError; end
  
  class APIError < Error
    attr_reader :status_code, :response_body, :request_id
    
    def initialize(message, status_code: nil, response_body: nil, request_id: nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
      @request_id = request_id
    end
    
    def to_s
      msg = super
      msg += " (#{status_code})" if status_code
      msg
    end
  end
  
  class AuthenticationError < APIError; end
  class RateLimitError < APIError; end
  class TimeoutError < APIError; end
  class ServerError < APIError; end
  class InvalidRequestError < APIError; end
end
```

## Phase 6: Entry Points

### 6.1 Client Factories
```ruby
# lib/zai.rb
require "zai/version"
require "zai/client"
require "zai/configuration"
require "zai/error"

module Zai
  def self.client(api_key: nil, base_url: nil, **options)
    Client.new(api_key: api_key, base_url: base_url, **options)
  end
  
  def self.overseas_client(api_key: nil, **options)
    Client.new(
      api_key: api_key,
      base_url: "https://api.z.ai/api/paas/v4",
      **options
    )
  end
  
  def self.china_client(api_key: nil, **options)
    Client.new(
      api_key: api_key,
      base_url: "https://open.bigmodel.cn/api/paas/v4",
      **options
    )
  end
end

# Convenience aliases
ZaiClient = Zai.method(:overseas_client)
ZhipuAiClient = Zai.method(:china_client)