# Z.ai Ruby SDK Comprehensive Implementation Plan

## Executive Summary

This implementation plan provides a detailed roadmap for creating the Z.ai Ruby SDK based on the OpenSpec specification and analysis of Python SDK patterns. The plan focuses on creating idiomatic Ruby code that follows community standards while maintaining compatibility with the Python SDK's functionality.

**Ruby Version Support:**
- Ruby >= 3.2.8 (updated from Ruby >= 3.0.0)
- JRuby >= 10.0.4.0 (updated from JRuby >= 9.4.0.0)

## 1. Implementation Phases

### Phase 1: Foundation (Week 1-2)
**Goal**: Establish core infrastructure and basic HTTP communication

**Deliverables**:
- Project scaffolding with gemspec
- Configuration management system
- HTTP client wrapper with authentication
- Basic error handling hierarchy
- CI/CD pipeline setup

**Key Files**:
```
lib/zai.rb                    # Main entry point
lib/zai/version.rb            # Version management
lib/zai/client.rb             # Core client
lib/zai/configuration.rb     # Configuration
lib/zai/http_connection.rb   # HTTP layer
lib/zai/error.rb              # Error classes
zai-ruby-sdk.gemspec          # Gem specification
```

### Phase 2: Authentication & Core Services (Week 3)
**Goal**: Implement robust authentication and retry mechanisms

**Deliverables**:
- API key authentication
- JWT token authentication with caching
- Retry mechanism with exponential backoff
- Comprehensive error handling

**Key Files**:
```
lib/zai/auth/
├── base.rb                   # Base authentication
├── api_key_auth.rb          # API key auth
└── jwt_auth.rb              # JWT auth with caching

lib/zai/concerns/
└── retryable.rb             # Retry logic

lib/zai/utils/
├── cache/
│   ├── memory_cache.rb      # In-memory cache
│   └── redis_cache.rb       # Redis cache (optional)
└── jwt.rb                   # JWT utilities
```

### Phase 3: Chat API MVP (Week 4-5)
**Goal**: Implement fully functional chat completions API

**Deliverables**:
- Non-streaming chat completions
- Streaming chat completions with Enumerator support
- Message model and validation
- Response parsing and object modeling

**Key Files**:
```
lib/zai/api/
├── base.rb                   # Base API class
└── chat.rb                   # Chat API implementation

lib/zai/models/
├── base.rb                   # Base model class
└── chat/
    ├── message.rb            # Message model
    ├── completion_response.rb # Response model
    ├── choice.rb             # Choice model
    └── usage.rb              # Usage statistics
```

### Phase 4: Extended APIs (Week 6-8)
**Goal**: Implement additional API endpoints

**Deliverables**:
- Embeddings API
- Image generation API
- Video generation API
- Audio processing API
- File management API

**Key Files**:
```
lib/zai/api/
├── embeddings.rb             # Embeddings API
├── images.rb                 # Image generation
├── videos.rb                 # Video generation
├── audio.rb                  # Audio processing
├── files.rb                  # File management
└── assistants.rb             # Assistant API

lib/zai/models/
├── embeddings/
│   ├── request.rb
│   └── response.rb
├── images/
├── videos/
└── audio/
```

### Phase 5: Advanced Features (Week 9-10)
**Goal**: Add advanced features and optimizations

**Deliverables**:
- Async support with async gem
- Type safety with RBS signatures
- Performance optimizations
- Rails integrations (optional)

**Key Files**:
```
lib/zai/async/                # Async support
sig/                          # RBS type signatures
lib/zai/rails/               # Rails integrations (optional)
```

### Phase 6: Testing & Documentation (Week 11-12)
**Goal**: Comprehensive test coverage and documentation

**Deliverables**:
- Full test suite with VCR recordings
- Documentation with YARD
- Usage examples
- Performance benchmarks

## 2. Code Architecture

### 2.1 Module Structure

```ruby
# Main module structure
module Zai
  # Version: defined in lib/zai/version.rb
  
  # Client: main client class in lib/zai/client.rb
  
  # Configuration: lib/zai/configuration.rb
  
  # Error: lib/zai/error.rb
  
  # API resources: lib/zai/api/
  
  # Models: lib/zai/models/
  
  # Authentication: lib/zai/auth/
  
  # Utilities: lib/zai/utils/
  
  # Concerns: lib/zai/concerns/
end
```

### 2.2 Class Hierarchy

```ruby
# Base classes
Zai::Client                    # Main client
Zai::Configuration             # Configuration management
Zai::Error                     # Base error class
Zai::API::Base                 # Base API class
Zai::Models::Base              # Base model class
Zai::Auth::Base                # Base auth class

# Concrete implementations
Zai::API::Chat                 # Chat API
Zai::API::Embeddings           # Embeddings API
# ... other APIs

Zai::Models::ChatMessage       # Message model
Zai::Models::ChatCompletionResponse # Response model
# ... other models

Zai::Auth::ApiKeyAuth          # API key authentication
Zai::Auth::JwtAuth             # JWT authentication
```

## 3. Ruby Version Requirements & Implications

### 3.1 Supported Ruby Versions

The Z.ai Ruby SDK supports the following Ruby versions:
- **Ruby >= 3.2.8** (updated from Ruby >= 3.0.0)
- **JRuby >= 10.0.4.0** (updated from JRuby >= 9.4.0.0)

### 3.2 Gem Specification Requirements

```ruby
# zai-ruby-sdk.gemspec
Gem::Specification.new do |spec|
  spec.name = "zai-ruby-sdk"
  spec.version = Zai::VERSION
  spec.authors = ["Z.ai Team"]
  spec.email = ["support@z.ai"]
  
  spec.summary = "Ruby SDK for Z.ai AI services"
  spec.description = "Official Ruby SDK for Z.ai's AI services, providing idiomatic Ruby interfaces to powerful AI models"
  spec.homepage = "https://github.com/z-ai-ruby/sdk"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.8"
  
  # Specify platform for JRuby compatibility
  spec.platform = Gem::Platform::RUBY
  
  # Metadata
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["source_code_uri"] = "https://github.com/z-ai-ruby/sdk"
  spec.metadata["changelog_uri"] = "https://github.com/z-ai-ruby/sdk/blob/main/CHANGELOG.md"
  
  # Files
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  # Dependencies
  spec.add_dependency "httparty", "~> 0.21"
  spec.add_dependency "jwt", "~> 2.7"
  spec.add_dependency "dry-struct", "~> 1.6"
  spec.add_dependency "dry-validation", "~> 1.9"
  
  # JRuby-specific dependencies
  if RUBY_ENGINE == 'jruby'
    spec.add_dependency "concurrent-ruby", "~> 1.2"
  end
  
  # Development dependencies for testing with RSpec
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rspec-core", "~> 3.12"
  spec.add_development_dependency "rspec-expectations", "~> 3.12"
  spec.add_development_dependency "rspec-mocks", "~> 3.12"
  spec.add_development_dependency "rspec-support", "~> 3.12"
  
  # RSpec HTTP mocking and testing tools
  spec.add_development_dependency "vcr", "~> 6.2"
  spec.add_development_dependency "webmock", "~> 3.19"
  
  # RSpec coverage and reporting
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "simplecov-json-formatter", "~> 0.1"
  
  # Documentation
  spec.add_development_dependency "yard", "~> 0.9"
  
  # Type checking
  spec.add_development_dependency "rbs", "~> 3.2"
  
  # RSpec performance testing
  spec.add_development_dependency "benchmark-memory", "~> 0.1"
  
  # Optional factory pattern support
  spec.add_development_dependency "factory_bot", "~> 6.2"
  spec.add_development_dependency "faker", "~> 3.2"
  
  # CI/CD test matrix
  spec.metadata["rubygems_mfa_required"] = "true"
end
```

### 3.3 Ruby 3.2+ Features We Can Leverage

Ruby 3.2.8+ introduces several features that can enhance our SDK:

1. **Data Class Pattern**: Ruby 3.2 introduced enhanced `data` keyword for immutable structs
```ruby
# Using Ruby 3.2+ data class for immutable models
data class ChatMessage
  attr_reader :role, :content, :name
  
  def initialize(role:, content:, name: nil)
    @role = role
    @content = content
    @name = name
  end
end
```

2. **Anonymous Syntax for Method Parameters**: Improved method signatures
```ruby
# Ruby 3.2+ allows more concise parameter definitions
def chat_completions(messages:, model: "glm-5", temperature: 0.7, **)
  # Implementation
end
```

3. **Performance Improvements**: Ruby 3.2 includes YJIT improvements and memory optimizations

4. **Pattern Matching Enhancements**: More robust pattern matching for response parsing
```ruby
# Enhanced pattern matching for API responses
case response
in { id:, model:, choices: [{ message: { content: } }] }
  # Extract content directly
in { error: { message:, type: } }
  # Handle error directly
else
  # Fallback handling
end
```

### 3.4 JRuby 10.0.4.0+ Optimizations

JRuby 10.0.4.0+ provides significant improvements we can leverage:

1. **True Parallelism**: JRuby can utilize multiple CPU cores
```ruby
# JRuby-specific concurrent processing
if RUBY_ENGINE == 'jruby'
  require 'concurrent-ruby'
  
  # Parallel processing for batch requests
  def parallel_completions(requests)
    pool = Concurrent::ThreadPoolExecutor.new(
      min_threads: 2,
      max_threads: 4
    )
    
    futures = requests.map do |request|
      Concurrent::Future.execute(executor: pool) do
        completions(request)
      end
    end
    
    futures.map(&:value)
  ensure
    pool.shutdown
    pool.wait_for_termination(30)
  end
end
```

2. **Java Integration**: Leverage Java libraries for performance-critical operations
```ruby
# JRuby-specific HTTP client using Java Netty
if RUBY_ENGINE == 'jruby'
  require 'java'
  
  class JRubyHTTPConnection
    def initialize(configuration)
      import 'java.net.http.HttpClient'
      import 'java.net.http.HttpRequest'
      import 'java.net.http.HttpResponse'
      
      @client = HttpClient.new
      @configuration = configuration
    end
    
    def post(path, body)
      request = HttpRequest.newBuilder
        .uri(java.net.URI.new("#{@configuration.base_url}#{path}"))
        .header("Content-Type", "application/json")
        .POST(HttpRequest.BodyPublishers.ofString(body.to_json))
        .build
      
      response = @client.send(request, HttpResponse.BodyHandlers.ofString)
      JSON.parse(response.body)
    end
  end
end
```

### 3.5 Testing Matrix Configuration

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby: ['3.2.8', '3.3.0']
        include:
          - ruby: '3.2.8'
            os: ubuntu-latest
          - ruby: '3.3.0'
            os: ubuntu-latest
          - ruby: 'jruby-10.0.4.0'
            os: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
      
      - name: Install dependencies
        run: bundle install --jobs 4 --retry 3
      
      - name: Run RSpec unit tests
        run: bundle exec rake spec_unit
      
      - name: Run RSpec integration tests
        run: bundle exec rake spec_integration
      
      - name: Generate RSpec coverage report
        run: bundle exec rake coverage
      
      - name: Run RBS type checking
        run: bundle exec rbs validate --root sig/
      
      - name: Generate YARD documentation
        run: bundle exec yard doc --output-dir .yardoc
      
      # JRuby-specific steps
      - name: JRuby concurrency tests
        if: matrix.ruby == 'jruby-10.0.4.0'
        run: bundle exec rake spec:jruby
```

### 3.6 Gemfile.lock Management

```ruby
# Gemfile
source "https://rubygems.org"

# Specify exact Ruby version requirement
ruby ">= 3.2.8"

# Core dependencies
gem "httparty", "~> 0.21"
gem "jwt", "~> 2.7"
gem "dry-struct", "~> 1.6"
gem "dry-validation", "~> 1.9"

# JRuby-specific gems
gem "concurrent-ruby", "~> 1.2", platforms: :jruby

# Development dependencies for RSpec testing
group :development, :test do
  gem "rake", "~> 13.0"
  
  # RSpec testing framework
  gem "rspec", "~> 3.12"
  gem "rspec-core", "~> 3.12"
  gem "rspec-expectations", "~> 3.12"
  gem "rspec-mocks", "~> 3.12"
  gem "rspec-support", "~> 3.12"
  
  # RSpec HTTP mocking and testing tools
  gem "vcr", "~> 6.2"
  gem "webmock", "~> 3.19"
  
  # RSpec coverage and reporting
  gem "simplecov", "~> 0.22"
  gem "simplecov-json-formatter", "~> 0.1"
  
  # Documentation
  gem "yard", "~> 0.9"
  
  # Type checking
  gem "rbs", "~> 3.2"
  
  # Ruby 3.2+ specific gems
  gem "benchmark", "~> 0.2"
  gem "memory_profiler", "~> 1.0"
  
  # JRuby-specific development gems
  gem "debase", platforms: :jruby
  gem "ruby-debug-ide", platforms: :jruby
end
```

### 3.7 Compatibility Layer

```ruby
# lib/zai/compatibility.rb
module Zai
  module Compatibility
    # Check Ruby version at runtime
    def self.ruby_version
      @ruby_version ||= Gem::Version.new(RUBY_VERSION)
    end
    
    def self.jruby?
      RUBY_ENGINE == 'jruby'
    end
    
    def self.ruby_32_plus?
      ruby_version >= Gem::Version.new('3.2.0')
    end
    
    # Feature detection methods
    def self.supports_data_classes?
      ruby_version >= Gem::Version.new('3.2.0')
    end
    
    def self.supports_enhanced_pattern_matching?
      ruby_version >= Gem::Version.new('3.2.0')
    end
    
    # Conditional feature implementation
    def self.create_model_class(name, attributes)
      if supports_data_classes?
        # Use Ruby 3.2+ data class
        Class.new(Data) do
          attributes.each do |attr|
            attr_accessor attr
          end
        end
      else
        # Fallback to Dry::Struct
        Class.new(Dry::Struct) do
          attributes.each do |attr|
            attribute attr, Types::String
          end
        end
      end
    end
  end
end
```

## 3.8 Ruby Implementation Details

### 3.1 Core Client Implementation

```ruby
# lib/zai/client.rb
require 'zai/configuration'
require 'zai/http_connection'

module Zai
  class Client
    attr_reader :configuration
    
    def initialize(**options)
      @configuration = Configuration.new(options)
      validate_configuration!
    end
    
    # API resources with lazy initialization
    def chat
      @chat ||= API::Chat.new(self)
    end
    
    def embeddings
      @embeddings ||= API::Embeddings.new(self)
    end
    
    def images
      @images ||= API::Images.new(self)
    end
    
    def videos
      @videos ||= API::Videos.new(self)
    end
    
    def audio
      @audio ||= API::Audio.new(self)
    end
    
    def files
      @files ||= API::Files.new(self)
    end
    
    def assistants
      @assistants ||= API::Assistants.new(self)
    end
    
    # Connection management
    def connection
      @connection ||= HTTPConnection.new(configuration)
    end
    
    private
    
    def validate_configuration!
      unless configuration.api_key
        raise ConfigurationError, "API key is required"
      end
    end
  end
end
```

### 3.2 Configuration System

```ruby
# lib/zai/configuration.rb
require 'zai/error'

module Zai
  class Configuration
    attr_accessor :api_key, :base_url, :timeout, :max_retries, 
                  :disable_token_cache, :source_channel, :cache
    
    def initialize(options = {})
      apply_defaults!
      apply_options(options)
      apply_env_vars!
      validate!
    end
    
    def for_overseas?
      base_url&.include?("api.z.ai") || default_overseas_url?
    end
    
    def for_china?
      base_url&.include?("bigmodel.cn") || default_china_url?
    end
    
    private
    
    def apply_defaults!
      @base_url = default_base_url
      @timeout = 30
      @max_retries = 3
      @disable_token_cache = true
      @source_channel = "ruby-sdk"
      @cache = nil
    end
    
    def apply_options(options)
      options.each { |key, value| send("#{key}=", value) if respond_to?("#{key}=") }
    end
    
    def apply_env_vars!
      @api_key ||= ENV["ZAI_API_KEY"]
      @base_url ||= ENV["ZAI_BASE_URL"]
      @timeout = ENV["ZAI_TIMEOUT"]&.to_i || @timeout
    end
    
    def validate!
      # URL validation
      if base_url && !valid_url?(base_url)
        raise ConfigurationError, "Invalid base URL format"
      end
    end
    
    def valid_url?(url)
      URI.parse(url).is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      false
    end
    
    def default_base_url
      overseas? ? "https://api.z.ai/api/paas/v4" : "https://open.bigmodel.cn/api/paas/v4"
    end
    
    def overseas?
      # Default to overseas unless explicitly configured for China
      ENV["ZAI_REGION"] != "china"
    end
  end
end
```

### 3.3 HTTP Client with Streaming Support

```ruby
# lib/zai/http_connection.rb
require 'httparty'
require 'zai/concerns/retryable'
require 'zai/error'

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
      
      if block_given?
        # Streaming with block
        response = @client.post(path, body: body.to_json, headers: headers, stream_response: true)
        handle_stream_response(response, &block)
      else
        # Return Enumerator for lazy evaluation
        to_enum(:stream_post, path, body)
      end
    end
    
    private
    
    def build_http_client
      HTTParty.persistent(configuration.base_url) do |http|
        http.timeout configuration.timeout
        http.open_timeout configuration.timeout / 2
        http.headers.update(build_headers)
        http.debug_output $stderr if ENV["ZAI_DEBUG"]
      end
    end
    
    def build_headers
      base_headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "User-Agent" => "ZaiRubySDK/#{Zai::VERSION}"
      }
      
      # Add language preference for overseas API
      if configuration.for_overseas?
        base_headers["Accept-Language"] = "en-US,en;q=0.9"
      end
      
      # Add authentication headers
      auth_headers = if configuration.disable_token_cache
        require 'zai/auth/api_key_auth'
        Auth::ApiKeyAuth.new(configuration.api_key, configuration.source_channel).headers
      else
        require 'zai/auth/jwt_auth'
        Auth::JwtAuth.new(
          configuration.api_key, 
          cache: configuration.cache,
          source_channel: configuration.source_channel
        ).headers
      end
      
      base_headers.merge(auth_headers)
    end
    
    def request(method, path, options = {})
      with_retries(max_retries: configuration.max_retries) do
        response = @client.public_send(method, path, options)
        handle_response(response)
      end
    rescue Timeout::Error => e
      raise TimeoutError.new("Request timeout", response_body: e.message)
    rescue HTTParty::Error => e
      raise APIError.new("HTTP client error: #{e.message}")
    end
    
    def handle_response(response)
      case response.code
      when 200..299
        parse_response(response)
      when 401
        raise AuthenticationError.new(
          "Authentication failed",
          status_code: response.code,
          response_body: response.body
        )
      when 429
        raise RateLimitError.new(
          "Rate limit exceeded",
          status_code: response.code,
          response_body: response.body
        )
      when 400
        raise InvalidRequestError.new(
          "Invalid request",
          status_code: response.code,
          response_body: response.body
        )
      when 500..599
        raise ServerError.new(
          "Server error",
          status_code: response.code,
          response_body: response.body
        )
      else
        raise APIError.new(
          "API error",
          status_code: response.code,
          response_body: response.body
        )
      end
    end
    
    def parse_response(response)
      return response.body if response.body.empty?
      
      JSON.parse(response.body)
    rescue JSON::ParserError
      response.body
    end
    
    def handle_stream_response(response, &block)
      response.body.each do |chunk|
        parsed_chunk = parse_stream_chunk(chunk)
        yield parsed_chunk if parsed_chunk && block_given?
      end
    end
    
    def parse_stream_chunk(chunk)
      lines = chunk.split("\n")
      data_lines = lines.select { |line| line.start_with?("data: ") }
      return nil if data_lines.empty?
      
      data_lines.each do |line|
        data = line.sub(/^data: /, "")
        return nil if data == "[DONE]"
        
        begin
          return JSON.parse(data)
        rescue JSON::ParserError
          # Skip invalid JSON lines
          next
        end
      end
      
      nil
    end
  end
end
```

### 3.4 Chat API Implementation with Ruby-style Streaming

```ruby
# lib/zai/api/chat.rb
require 'zai/api/base'
require 'zai/models/chat/message'
require 'zai/models/chat/completion_response'

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
          # Block-style streaming (Ruby idiomatic)
          stream("/chat/completions", request_body) do |chunk|
            yield parse_stream_chunk(chunk)
          end
        else
          # Return Enumerator for functional-style usage
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
          top_p: options[:top_p],
          **options.except(:temperature, :max_tokens, :stream, :top_p)
        }
      end
      
      def normalize_messages(messages)
        case messages
        when Array
          messages.map do |msg|
            case msg
            when Hash
              Models::ChatMessage.new(msg)
            when Models::ChatMessage
              msg
            else
              raise ArgumentError, "Message must be a Hash or ChatMessage"
            end
          end
        when String
          [Models::ChatMessage.new(role: "user", content: messages)]
        else
          raise ArgumentError, "Messages must be an array or string"
        end
      end
      
      def parse_stream_chunk(chunk)
        return nil unless chunk.is_a?(Hash)
        
        # Extract relevant data for streaming response
        {
          id: chunk["id"],
          object: chunk["object"],
          created: chunk["created"],
          model: chunk["model"],
          choices: chunk["choices"]&.map do |choice|
            {
              index: choice["index"],
              delta: choice["delta"],
              finish_reason: choice["finish_reason"]
            }
          end
        }
      end
    end
  end
end
```

### 3.5 Type-safe Models with Dry::Struct

```ruby
# lib/zai/models/base.rb
require 'dry-struct'
require 'dry/types'

module Zai
  module Models
    module Types
      include Dry::Types()
    end
    
    class Base < Dry::Struct
      transform_keys(&:to_sym)
    end
  end
end

# lib/zai/models/chat/message.rb
require 'zai/models/base'

module Zai
  module Models
    class ChatMessage < Base
      attribute :role, Types::String.enum("system", "user", "assistant")
      attribute :content, Types::String
      attribute :name, Types::String.optional
      
      def to_h
        super.reject { |_, v| v.nil? }
      end
      
      def user?
        role == "user"
      end
      
      def assistant?
        role == "assistant"
      end
      
      def system?
        role == "system"
      end
    end
  end
end

# lib/zai/models/chat/completion_response.rb
require 'zai/models/base'
require 'zai/models/chat/choice'
require 'zai/models/shared/usage'

module Zai
  module Models
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
      
      def first_choice
        choices.first
      end
      
      def usage
        super || Usage.new
      end
    end
  end
end
```

### 3.6 Authentication with JWT Caching

```ruby
# lib/zai/auth/jwt_auth.rb
require 'jwt'
require 'zai/auth/base'

module Zai
  module Auth
    class JwtAuth < Base
      attr_reader :api_key, :cache, :ttl, :source_channel
      
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
        id, secret = parse_api_key
        
        payload = {
          api_key: id,
          exp: calculate_expiry,
          timestamp: Time.now.to_i
        }
        
        token = JWT.encode(payload, secret, "HS256", { typ: "JWT", alg: "HS256" })
        cache.set("jwt_token", token, ttl: ttl) if cache
        
        token
      rescue JWT::EncodeError => e
        raise Zai::Error, "Failed to generate JWT token: #{e.message}"
      end
      
      def parse_api_key
        parts = api_key.split(".")
        raise Zai::Error, "Invalid API key format" unless parts.size == 2
        parts
      end
      
      def calculate_expiry
        (Time.now + ttl).to_i
      end
    end
  end
end
```

## 4. RSpec Testing Strategy

**This implementation plan specifies RSpec as the exclusive testing framework for the Z.ai Ruby SDK.** All testing should follow RSpec conventions, patterns, and best practices. RSpec provides idiomatic Ruby testing with expressive behavior-driven development (BDD) syntax that aligns with Ruby community standards.

### 4.1 RSpec Framework Specification

This implementation plan specifies **RSpec** as the primary testing framework for the Z.ai Ruby SDK. RSpec provides idiomatic Ruby testing patterns with expressive behavior-driven development (BDD) syntax that aligns with Ruby community best practices.

### 4.2 RSpec Directory Structure

```
spec/
├── spec_helper.rb                 # RSpec configuration with required setup
├── rails_helper.rb               # Rails-specific configuration (optional)
├── .rspec                        # RSpec configuration file
├── support/
│   ├── vcr_setup.rb              # VCR configuration for HTTP mocking
│   ├── webmock_helpers.rb        # WebMock helpers for stubbing
│   ├── fixtures/                 # Test data and JSON fixtures
│   │   ├── chat_completion.json
│   │   ├── embeddings_response.json
│   │   ├── stream_chunks.txt
│   │   └── error_responses/
│   └── shared_contexts/          # RSpec shared contexts
│       ├── api_client_context.rb
│       ├── authentication_context.rb
│       └── mock_responses_context.rb
├── shared_examples/              # RSpec shared example groups
│   ├── api_resource_behavior.rb  # Common API behavior
│   ├── authentication_behavior.rb
│   ├── error_handling_behavior.rb
│   └── model_behavior.rb
├── zai/
│   ├── client_spec.rb            # Client initialization and configuration
│   ├── configuration_spec.rb     # Configuration validation and defaults
│   ├── http_connection_spec.rb   # HTTP layer tests
│   ├── auth/
│   │   ├── api_key_auth_spec.rb
│   │   └── jwt_auth_spec.rb
│   ├── api/
│   │   ├── base_spec.rb
│   │   ├── chat_spec.rb
│   │   ├── embeddings_spec.rb
│   │   ├── images_spec.rb
│   │   ├── videos_spec.rb
│   │   ├── audio_spec.rb
│   │   ├── files_spec.rb
│   │   └── assistants_spec.rb
│   ├── models/
│   │   ├── base_spec.rb
│   │   └── chat/
│   │       ├── message_spec.rb
│   │       ├── completion_response_spec.rb
│   │       └── choice_spec.rb
│   ├── concerns/
│   │   └── retryable_spec.rb
│   └── utils/
│       ├── cache_spec.rb
│       └── jwt_spec.rb
├── factories/                    # Test data factories (optional)
│   ├── chat_messages.rb
│   ├── api_responses.rb
│   └── configurations.rb
└── integration/
    ├── chat_api_spec.rb         # Full API integration tests
    ├── streaming_spec.rb        # Streaming integration tests
    └── performance_spec.rb      # Performance benchmarks
```

### 4.3 RSpec Implementation Examples

```ruby
# spec/zai/api/chat_spec.rb
require 'spec_helper'
require 'support/shared_examples/api_resource_behavior'

RSpec.describe Zai::API::Chat, type: :api do
  include_context 'api client context'
  include_context 'mock responses'
  
  let(:chat) { described_class.new(client) }
  
  describe "#completions" do
    context "with string message" do
      it "creates chat completion", :vcr do
        response = chat.completions(messages: "Hello, world!", model: "glm-5")
        
        expect(response).to be_a(Zai::Models::ChatCompletionResponse)
        expect(response.choices).not_to be_empty
        expect(response.first_message).to be_a(String)
      end
    end
    
    context "with array of messages" do
      it "creates chat completion with conversation history", :vcr do
        messages = [
          { role: "system", content: "You are a helpful assistant." },
          { role: "user", content: "Hello!" },
          { role: "assistant", content: "Hi! How can I help?" },
          { role: "user", content: "What's 2+2?" }
        ]
        
        response = chat.completions(messages: messages)
        
        expect(response).to be_a(Zai::Models::ChatCompletionResponse)
        expect(response.choices.first.message.content).to include("4")
      end
    end
    
    context "with invalid messages" do
      it "raises ArgumentError" do
        expect {
          chat.completions(messages: 123)
        }.to raise_error(ArgumentError, "Messages must be an array or string")
      end
    end
    
    it_behaves_like "an API resource", :chat_completions
  end
  
  describe "#stream" do
    context "with block" do
      it "streams completion chunks", :vcr do
        messages = [{ role: "user", content: "Count to 5" }]
        chunks = []
        
        chat.stream(messages: messages) do |chunk|
          chunks << chunk
        end
        
        expect(chunks).not_to be_empty
        expect(chunks.first).to have_key(:choices)
      end
    end
    
    context "without block" do
      it "returns Enumerator", :vcr do
        messages = [{ role: "user", content: "Hello" }]
        
        enum = chat.stream(messages: messages)
        expect(enum).to be_a(Enumerator)
        
        first_chunk = enum.first
        expect(first_chunk).to have_key(:choices)
      end
    end
  end
end
```

### 4.4 RSpec Configuration

#### 4.4.1 Basic RSpec Setup

```ruby
# spec/spec_helper.rb
require 'rspec'
require 'webmock/rspec'
require 'vcr'
require 'simplecov'

# Enable SimpleCov for code coverage
SimpleCov.start do
  add_filter '/spec/'
  add_group 'Libraries', 'lib/zai'
  minimum_coverage 90
  minimum_coverage_by_file 80
end

# Require library
require_relative '../lib/zai'

# RSpec configuration
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_dsl_metadata!
  
  # Use expect syntax instead of should
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  
  # Use RSpec's mocking framework
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  
  # Shared context metadata
  config.shared_context_metadata_behavior = :apply_to_host_groups
  
  # Configure ordering
  config.order = :random
  Kernel.srand config.seed
  
  # Filter lines from Rails gems in backtraces
  config.filter_rails_from_backtrace!
  
  # Before/after hooks
  config.before(:suite) do
    # Setup test environment
  end
  
  config.after(:suite) do
    # Cleanup test environment
  end
end
```

#### 4.4.2 RSpec Configuration File

```ruby
# .rspec
--require spec_helper
--color
--format documentation
--order random
```

#### 4.4.3 VCR Configuration for RSpec

```ruby
# spec/support/vcr_setup.rb
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path("../fixtures/vcr_cassettes", __dir__)
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
  
  # Filter sensitive data from cassettes
  config.filter_sensitive_data('<API_KEY>') do |interaction| 
    interaction.request.headers['Authorization']&.first&.match(/Bearer\s+(.+)/)&.[](1)
  end
  
  config.filter_sensitive_data('<JWT_TOKEN>') do |interaction|
    interaction.request.headers['Authorization']&.first&.match(/Bearer\s+(.+)/)&.[](1)
  end
  
  # Clean request headers
  config.before_http_request do |request|
    # Normalize headers to avoid cassette mismatches
    request.headers['User-Agent'] = '<USER_AGENT>'
    request.headers['X-Request-ID'] = '<REQUEST_ID>' if request.headers['X-Request-ID']
  end
  
  # Custom cassette naming strategy for RSpec
  config.define_cassette_placeholder('<RSpec.description>') do |interaction|
    # Use RSpec metadata for cassette naming when available
    RSpec.current_example.metadata[:description] if RSpec.respond_to?(:current_example)
  end
end

RSpec.configure do |config|
  # Enable VCR with metadata
  config.around(:each, :vcr) do |example|
    cassette_name = example.metadata[:cassette_name] || 
                   example.metadata[:full_description].gsub(/\s+/, '_').gsub(/[^\w\-_]/, '_')
    
    VCR.use_cassette(cassette_name, record: :once, match_requests_on: [:method, :uri, :body]) do
      example.run
    end
  end
end
```

### 4.5 RSpec Performance Tests and Benchmarks

```ruby
# spec/performance/chat_performance_spec.rb
require 'benchmark'
require 'memory_profiler'
require 'spec_helper'

RSpec.describe "Chat API Performance", type: :performance do
  let(:client) { Zai::Client.new(api_key: ENV["ZAI_API_KEY"]) }
  
  describe "response time" do
    it "responds within reasonable time", :vcr do
      time = Benchmark.realtime do
        client.chat.completions(messages: "Hello", max_tokens: 10)
      end
      
      expect(time).to be < 5.0 # 5 seconds
    end
    
    it "handles concurrent requests efficiently", :vcr do
      threads = []
      start_time = Time.now
      
      5.times do
        threads << Thread.new do
          client.chat.completions(messages: "Hello", max_tokens: 10)
        end
      end
      
      threads.each(&:join)
      end_time = Time.now
      
      # Should complete faster than sequential execution
      expect(end_time - start_time).to be < 10.0
    end
  end
  
  describe "memory usage" do
    it "doesn't leak memory during streaming", :vcr do
      messages = [{ role: "user", content: "Generate a long story" }]
      
      report = MemoryProfiler.report do
        chunks = []
        client.chat.stream(messages: messages) { |chunk| chunks << chunk }
      end
      
      # Memory usage should be reasonable
      expect(report.total_allocated_memsize).to be < 5_000_000 # 5MB
      expect(report.total_retained_memsize).to be < 1_000_000 # 1MB
    end
  end
end
```

### 4.6 RSpec Custom Matchers

```ruby
# spec/support/matchers/zai_matchers.rb
RSpec::Matchers.define :be_a_zai_error do |expected_error_type|
  match do |actual|
    actual.is_a?(Zai::Error) && 
    (expected_error_type.nil? || actual.is_a?(expected_error_type))
  end
  
  description { "be a Z.ai #{expected_error_type || 'error'}" }
  
  failure_message do |actual|
    "expected #{actual.inspect} to be a Z.ai #{expected_error_type || 'error'}"
  end
end

RSpec::Matchers.define :have_valid_chat_response do
  match do |response|
    response.is_a?(Zai::Models::ChatCompletionResponse) &&
    response.respond_to?(:choices) &&
    response.respond_to?(:usage) &&
    response.choices.is_a?(Array)
  end
  
  description { "have a valid chat response structure" }
end

RSpec::Matchers.define :stream_chunks do |expected_count|
  match do |stream_block|
    @chunks = []
    stream_block.call { |chunk| @chunks << chunk }
    
    if expected_count
      @chunks.size == expected_count
    else
      !@chunks.empty?
    end
  end
  
  description { "stream #{expected_count || 'some'} chunks" }
  
  failure_message do
    if expected_count
      "expected to stream exactly #{expected_count} chunks, but got #{@chunks.size}"
    else
      "expected to stream at least one chunk"
    end
  end
end

RSpec.configure do |config|
  config.include Matchers
end
```

### 4.9 RSpec Test Fixtures and Factories

```ruby
# spec/support/factory_bot.rb
require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot.define do
  factory :chat_message, class: Zai::Models::ChatMessage do
    sequence(:content) { |n| "Test message #{n}" }
    role { "user" }
    
    trait :system do
      role { "system" }
    end
    
    trait :assistant do
      role { "assistant" }
    end
    
    trait :with_name do
      name { "TestUser" }
    end
  end
  
  factory :chat_choice, class: Zai::Models::ChatChoice do
    index { 0 }
    message { association :chat_message, :assistant }
    finish_reason { "stop" }
  end
  
  factory :usage, class: Zai::Models::Usage do
    prompt_tokens { 10 }
    completion_tokens { 20 }
    total_tokens { 30 }
  end
  
  factory :chat_completion_response, class: Zai::Models::ChatCompletionResponse do
    sequence(:id) { |n| "chatcmpl-#{n}" }
    created { Time.now.to_i }
    model { "glm-5" }
    
    choices { [association(:chat_choice)] }
    usage { association(:usage) }
  end
  
  factory :configuration, class: Zai::Configuration do
    api_key { "test-api-key" }
    base_url { "https://api.test.z.ai/api/paas/v4" }
    timeout { 30 }
    max_retries { 3 }
    source_channel { "ruby-sdk-test" }
  end
end
```

### 4.10 RSpec WebMock Integration

```ruby
# spec/support/webmock_helpers.rb
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:suite) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
  
  config.after(:suite) do
    WebMock.allow_net_connect!
  end
end

module WebMockHelpers
  def stub_chat_completion_response(options = {})
    response_body = build_chat_completion_response(options).to_json
    
    stub_request(:post, /api\.z\.ai.*\/chat\/completions/)
      .with(
        headers: {
          'Authorization' => /Bearer.*/,
          'Content-Type' => 'application/json'
        }
      )
      .to_return(
        status: options[:status] || 200,
        body: response_body,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
  
  def stub_streaming_response(options = {})
    streaming_data = build_streaming_chunks(options)
    
    stub_request(:post, /api\.z\.ai.*\/chat\/completions/)
      .with(
        headers: {
          'Authorization' => /Bearer.*/,
          'Content-Type' => 'application/json'
        },
        body: hash_including({ stream: true })
      )
      .to_return(
        status: 200,
        body: streaming_data,
        headers: { 'Content-Type' => 'text/plain; charset=utf-8' }
      )
  end
  
  def stub_error_response(status, error_type, message = nil)
    error_body = {
      error: {
        type: error_type,
        message: message || default_error_message(error_type)
      }
    }.to_json
    
    stub_request(:any, /api\.z\.ai/)
      .to_return(
        status: status,
        body: error_body,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
  
  private
  
  def build_chat_completion_response(options = {})
    {
      id: "chatcmpl-#{SecureRandom.hex(8)}",
      object: "chat.completion",
      created: Time.now.to_i,
      model: options[:model] || "glm-5",
      choices: options[:choices] || [
        {
          index: 0,
          message: {
            role: "assistant",
            content: options[:content] || "Test response"
          },
          finish_reason: options[:finish_reason] || "stop"
        }
      ],
      usage: options[:usage] || {
        prompt_tokens: 10,
        completion_tokens: 20,
        total_tokens: 30
      }
    }
  end
  
  def build_streaming_chunks(options = {})
    chunks = []
    
    # Add initial chunk
    chunks << "data: {\"id\":\"chatcmpl-#{SecureRandom.hex(4)}\",\"object\":\"chat.completion.chunk\",\"created\":#{Time.now.to_i},\"model\":\"glm-5\",\"choices\":[{\"index\":0,\"delta\":{\"role\":\"assistant\"},\"finish_reason\":null}]}\n\n"
    
    # Add content chunks
    (options[:content] || "Test response").split('').each do |char|
      chunks << "data: {\"id\":\"chatcmpl-#{SecureRandom.hex(4)}\",\"object\":\"chat.completion.chunk\",\"created\":#{Time.now.to_i},\"model\":\"glm-5\",\"choices\":[{\"index\":0,\"delta\":{\"content\":\"#{char}\"},\"finish_reason\":null}]}\n\n"
    end
    
    # Add final chunk
    chunks << "data: {\"id\":\"chatcmpl-#{SecureRandom.hex(4)}\",\"object\":\"chat.completion.chunk\",\"created\":#{Time.now.to_i},\"model\":\"glm-5\",\"choices\":[{\"index\":0,\"delta\":{},\"finish_reason\":\"stop\"}]}\n\n"
    chunks << "data: [DONE]\n\n"
    
    chunks.join
  end
  
  def default_error_message(error_type)
    case error_type.to_sym
    when :authentication_error
      "Invalid API key provided"
    when :rate_limit_error
      "Rate limit exceeded"
    when :invalid_request_error
      "Invalid request"
    when :server_error
      "Internal server error"
    else
      "An error occurred"
    end
  end
end

RSpec.configure do |config|
  config.include WebMockHelpers
end
```

## 5. Git Workflow Plan

### 5.1 Branching Strategy

```
main                          # Production releases
├── develop                   # Integration branch
├── feature/chat-api          # Feature branch
├── feature/embeddings-api    # Another feature branch
├── feature/jwt-auth         # Feature branch
├── hotfix/critical-bug      # Hotfix branch
└── release/v1.0.0           # Release preparation
```

### 5.2 Commit Convention

Using conventional commits for automated changelog generation:

```
feat: Add chat completions API
fix: Handle JWT token expiration
docs: Update README with installation guide
refactor: Extract authentication to separate module
test: Add VCR cassettes for chat API
chore: Update gem dependencies
```

### 5.3 Pull Request Process

1. **Create feature branch** from `develop`
2. **Implement changes** with tests
3. **Run full test suite** locally
4. **Create pull request** with detailed description
5. **Code review** by at least one team member
6. **CI/CD pipeline** runs automatically
7. **Merge** after approval and passing tests

### 5.4 Release Strategy

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby: ['3.2.8', '3.3.0']
    steps:
      - uses: actions/checkout@v3
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
      - name: Build and publish gem
        run: |
          gem build zai-ruby-sdk.gemspec
          gem push zai-ruby-sdk-*.gem
        env:
          RUBYGEMS_API_KEY: ${{ secrets.RUBYGEMS_API_KEY }}
      - name: Create GitHub Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  # JRuby-specific testing
  jruby-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup JRuby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: jruby-10.0.4.0
      - name: Install dependencies
        run: bundle install
      - name: Run tests
        run: bundle exec rake spec
```

## 6. Documentation Examples

### 6.1 Quick Start Guide

```ruby
# examples/quick_start.rb
require 'zai'

# Initialize client with API key
client = Zai.overseas_client(api_key: ENV["ZAI_API_KEY"])

# Simple chat completion
response = client.chat.completions(
  messages: "Hello, Z.ai! Tell me a joke.",
  model: "glm-5",
  max_tokens: 100
)

puts response.first_message

# Streaming chat completion
puts "Streaming response:"
client.chat.stream(messages: "Count to 10") do |chunk|
  delta = chunk.dig(:choices, 0, :delta, :content)
  print delta if delta
end
puts "\nDone!"

# Conversation with context
messages = [
  { role: "system", content: "You are a Ruby programming expert." },
  { role: "user", content: "What's the difference between Proc and lambda?" }
]

response = client.chat.completions(messages: messages)
puts response.first_message
```

### 6.2 README Structure

```markdown
# Z.ai Ruby SDK

[![Gem Version](https://badge.fury.io/rb/zai-ruby-sdk.svg)](https://badge.fury.io/rb/zai-ruby-sdk)
[![Build Status](https://github.com/z-ai-ruby/sdk/workflows/CI/badge.svg)](https://github.com/z-ai-ruby/sdk/actions)
[![Documentation](https://yardoc.org/badges/github/z-ai-ruby/sdk.svg)](https://yardoc.org/github/z-ai-ruby/sdk)

The official Ruby SDK for Z.ai's AI services, providing idiomatic Ruby interfaces to powerful AI models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zai-ruby-sdk'
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install zai-ruby-sdk
```

## Quick Start

```ruby
require 'zai'

# Initialize client
client = Zai.overseas_client(api_key: "your-api-key")

# Chat completion
response = client.chat.completions(
  messages: "Hello, world!",
  model: "glm-5"
)

puts response.first_message
```

## Features

- 🚀 Simple, idiomatic Ruby interface
- 💬 Chat completions with streaming support
- 🔍 Text embeddings
- 🖼️ Image generation
- 🎥 Video generation
- 🔊 Audio processing
- 📁 File management
- 🔐 Robust authentication (API key & JWT)
- 🔄 Automatic retry mechanism
- 🧪 Comprehensive test coverage
- 📖 Full API documentation

## Usage

### Chat Completions

See [examples/chat_completions.rb](examples/chat_completions.rb) for detailed examples.

### Streaming Responses

Ruby-style streaming with blocks or Enumerators:

```ruby
# Block style
client.chat.stream(messages: "Tell me a story") do |chunk|
  print chunk.dig(:choices, 0, :delta, :content)
end

# Enumerator style
enumerator = client.chat.stream(messages: "Explain quantum computing")
enumerator.each { |chunk| print chunk.dig(:choices, 0, :delta, :content) }
```

### Configuration

```ruby
client = Zai.client(
  api_key: "your-key",
  base_url: "https://api.z.ai/api/paas/v4",
  timeout: 30,
  max_retries: 3,
  disable_token_cache: false
)
```

## API Reference

Full API documentation is available at [https://rubydoc.info/gems/zai-ruby-sdk](https://rubydoc.info/gems/zai-ruby-sdk)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/z-ai-ruby/sdk.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
```

### 6.3 API Documentation with YARD

```ruby
# lib/zai/api/chat.rb
module Zai
  module API
    # Chat API for generating completions using Z.ai's language models
    #
    # @example Simple completion
    #   response = chat.completions(
    #     messages: "Hello, world!",
    #     model: "glm-5"
    #   )
    #   puts response.first_message
    #
    # @example Streaming completion with block
    #   chat.stream(messages: "Count to 10") do |chunk|
    #     print chunk.dig(:choices, 0, :delta, :content)
    #   end
    #
    # @example Streaming with Enumerator
    #   enum = chat.stream(messages: "Explain Ruby")
    #   enum.each { |chunk| process_chunk(chunk) }
    #
    # @example Conversation with context
    #   messages = [
    #     { role: "system", content: "You are a helpful assistant." },
    #     { role: "user", content: "What is Ruby?" }
    #   ]
    #   response = chat.completions(messages: messages)
    #
    class Chat < Base
      # Generate chat completions using Z.ai's language models
      #
      # @param messages [String, Array<Hash, ChatMessage>] The conversation messages
      # @param model [String] The model to use (default: "glm-5")
      # @param temperature [Float] Sampling temperature (0.0-1.0)
      # @param max_tokens [Integer] Maximum tokens in response
      # @param top_p [Float] Nucleus sampling parameter
      # @param stream [Boolean] Whether to stream the response
      # @param options [Hash] Additional options
      #
      # @return [ChatCompletionResponse] The completion response
      #
      # @raise [InvalidRequestError] When request parameters are invalid
      # @raise [AuthenticationError] When authentication fails
      # @raise [RateLimitError] When rate limit is exceeded
      # @raise [ServerError] When server error occurs
      #
      # @example Simple request
      #   response = completions(
      #     messages: "Hello, world!",
      #     model: "glm-5",
      #     max_tokens: 100
      #   )
      #
      # @example With array of messages
      #   messages = [
      #     { role: "system", content: "You are a helpful assistant." },
      #     { role: "user", content: "What is 2+2?" }
      #   ]
      #   response = completions(messages: messages)
      def completions(messages:, model: "glm-5", **options)
        # Implementation...
      end
      
      # Stream chat completions in real-time
      #
      # When called with a block, yields each chunk as it arrives.
      # When called without a block, returns an Enumerator for lazy processing.
      #
      # @param messages [String, Array<Hash, ChatMessage>] The conversation messages
      # @param model [String] The model to use (default: "glm-5")
      # @param temperature [Float] Sampling temperature (0.0-1.0)
      # @param max_tokens [Integer] Maximum tokens in response
      # @param top_p [Float] Nucleus sampling parameter
      # @param options [Hash] Additional options
      # @yield [chunk] Each streaming chunk as it arrives
      # @yieldparam chunk [Hash] The streaming chunk data
      #
      # @return [Enumerator, nil] Enumerator when called without block
      #
      # @example Block-style streaming
      #   stream(messages: "Tell me a story") do |chunk|
      #     print chunk.dig(:choices, 0, :delta, :content)
      #   end
      #
      # @example Enumerator-style streaming
      #   enum = stream(messages: "Count to 10")
      #   enum.each { |chunk| process_chunk(chunk) }
      def stream(messages:, model: "glm-5", **options, &block)
        # Implementation...
      end
    end
  end
end
```

## 7. RBS Type Signatures

### 7.1 Client Signatures

```rbs
# sig/zai/client.rbs
module Zai
  class Client
    attr_reader configuration: Configuration
    
    def initialize: (**untyped) -> void
    
    def chat: () -> API::Chat
    def embeddings: () -> API::Embeddings
    def images: () -> API::Images
    def videos: () -> API::Videos
    def audio: () -> API::Audio
    def files: () -> API::Files
    def assistants: () -> API::Assistants
    
    private
    
    def connection: () -> HTTPConnection
    def validate_configuration!: () -> void
  end
end
```

### 7.2 API Signatures

```rbs
# sig/zai/api/chat.rbs
module Zai
  module API
    class Chat
      include Base
      
      def initialize: (Client client) -> void
      
      def completions: (
        messages: String | Array[Hash[String, untyped] | Models::ChatMessage],
        ?model: String,
        **untyped options
      ) -> Models::ChatCompletionResponse
      
      def stream: (
        messages: String | Array[Hash[String, untyped] | Models::ChatMessage],
        ?model: String,
        **untyped options
      ) -> Enumerator[Hash, void] ?
      
      private
      
      def build_completion_request: (
        messages: String | Array[Hash[String, untyped] | Models::ChatMessage],
        model: String,
        options: Hash[Symbol, untyped]
      ) -> Hash[Symbol, untyped]
      
      def normalize_messages: (String | Array[Hash[String, untyped] | Models::ChatMessage]) -> Array[Models::ChatMessage]
      def parse_stream_chunk: (Hash[Symbol, untyped]) -> Hash[Symbol, untyped]?
    end
  end
end
```

## 8. Ruby Version Support & Testing Strategy

### 8.1 Testing Matrix

The SDK will be tested against the following Ruby versions:
- Ruby 3.2.8 (minimum supported version)
- Ruby 3.3.x (latest stable)
- JRuby 10.0.4.0+ (minimum supported JRuby)

### 8.2 Gemspec Configuration

```ruby
# zai-ruby-sdk.gemspec
Gem::Specification.new do |spec|
  # ... other configuration ...
  
  # Minimum Ruby version requirement
  spec.required_ruby_version = ">= 3.2.8"
  
  # Platform-specific dependencies
  if RUBY_ENGINE == 'jruby'
    spec.add_dependency "concurrent-ruby", "~> 1.2"
  end
  
  # Development dependencies for testing with RSpec
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rspec-core", "~> 3.12"
  spec.add_development_dependency "rspec-expectations", "~> 3.12"
  spec.add_development_dependency "rspec-mocks", "~> 3.12"
  spec.add_development_dependency "rspec-support", "~> 3.12"
  
  # RSpec HTTP mocking and testing tools
  spec.add_development_dependency "vcr", "~> 6.2"
  spec.add_development_dependency "webmock", "~> 3.19"
  
  # RSpec coverage and reporting
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "simplecov-json-formatter", "~> 0.1"
  
  # Documentation
  spec.add_development_dependency "yard", "~> 0.9"
  
  # Type checking
  spec.add_development_dependency "rbs", "~> 3.2"
  
  # RSpec performance testing
  spec.add_development_dependency "benchmark-memory", "~> 0.1"
  
  # Optional factory pattern support
  spec.add_development_dependency "factory_bot", "~> 6.2"
  spec.add_development_dependency "faker", "~> 3.2"
end
```

### 4.7 Rakefile for RSpec Testing

```ruby
# Rakefile
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# Default task
task :default => :spec

# Run all RSpec tests
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = '--order random'
end

# Run RSpec tests with coverage
desc 'Run specs with coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].invoke
end

# Run only unit tests
desc 'Run unit tests'
RSpec::Core::RakeTask.new(:spec_unit) do |t|
  t.pattern = 'spec/zai/**/*_spec.rb'
  t.rspec_opts = '--tag ~integration --tag ~performance'
end

# Run only integration tests
desc 'Run integration tests'
RSpec::Core::RakeTask.new(:spec_integration) do |t|
  t.pattern = 'spec/integration/**/*_spec.rb'
  t.rspec_opts = '--tag integration'
end

# Run only performance tests
desc 'Run performance tests'
RSpec::Core::RakeTask.new(:spec_performance) do |t|
  t.pattern = 'spec/performance/**/*_spec.rb'
  t.rspec_opts = '--tag performance'
end

# Run tests with specific pattern
desc 'Run tests matching pattern'
task :spec_pattern, :pattern do |t, args|
  pattern = args[:pattern] || '**/*_spec.rb'
  sh "bundle exec rspec spec/#{pattern}"
end

# Documentation task
require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', '-', 'CHANGELOG.md']
  t.options = ['--markup', 'markdown']
end

# Type checking task
desc 'Run RBS type checking'
task :typecheck do
  sh 'bundle exec rbs validate --root sig/'
end

# Run all checks
desc 'Run all checks (specs, coverage, type checking)'
task :check => [:coverage, :typecheck]
```

### 4.8 RSpec Shared Contexts and Example Groups

```ruby
# spec/support/shared_contexts/api_client_context.rb
RSpec.shared_context 'api client context' do
  let(:api_key) { 'test-api-key' }
  let(:base_url) { 'https://api.test.z.ai/api/paas/v4' }
  let(:client) { Zai::Client.new(api_key: api_key, base_url: base_url) }
  let(:configuration) { client.configuration }
  
  before do
    # Configure client for testing
    allow(configuration).to receive(:for_overseas?).and_return(true)
  end
end

# spec/support/shared_contexts/authentication_context.rb
RSpec.shared_context 'authentication context' do
  let(:valid_api_key) { 'test-id.test-secret' }
  let(:invalid_api_key) { 'invalid-key' }
  
  before do
    # Mock JWT token generation for tests
    allow_any_instance_of(Zai::Auth::JwtAuth)
      .to receive(:generate_token)
      .and_return('mock-jwt-token')
  end
end

# spec/support/shared_contexts/mock_responses_context.rb
RSpec.shared_context 'mock responses context' do
  let(:chat_response_fixture) do
    JSON.parse(File.read(File.join(__dir__, '../fixtures/chat_completion.json')))
  end
  
  let(:streaming_response_fixture) do
    File.read(File.join(__dir__, '../fixtures/stream_chunks.txt'))
  end
  
  let(:error_response_fixture) do
    JSON.parse(File.read(File.join(__dir__, '../fixtures/error_responses/api_error.json')))
  end
end

# spec/shared_examples/api_resource_behavior.rb
RSpec.shared_examples 'an API resource' do |resource_name|
  describe "##{resource_name}" do
    it 'returns a parsed response object' do
      response = subject.send(resource_name)
      expect(response).to respond_to(:choices)
    end
    
    it 'handles authentication errors' do
      stub_request(:post, /#{base_url}/)
        .to_return(status: 401, body: '{"error": "Unauthorized"}')
      
      expect {
        subject.send(resource_name)
      }.to raise_error(Zai::AuthenticationError)
    end
    
    it 'handles rate limit errors' do
      stub_request(:post, /#{base_url}/)
        .to_return(status: 429, body: '{"error": "Rate limit exceeded"}')
      
      expect {
        subject.send(resource_name)
      }.to raise_error(Zai::RateLimitError)
    end
    
    it 'handles server errors' do
      stub_request(:post, /#{base_url}/)
        .to_return(status: 500, body: '{"error": "Internal server error"}')
      
      expect {
        subject.send(resource_name)
      }.to raise_error(Zai::ServerError)
    end
  end
end
```

### 8.3 Ruby 3.2+ Features Implementation

#### 8.3.1 Data Class Implementation

```ruby
# lib/zai/models/data_class.rb
module Zai
  module Models
    module DataClass
      def self.included(base)
        if Zai::Compatibility.supports_data_classes?
          base.extend(ClassMethods)
        end
      end
      
      module ClassMethods
        def data_class(*attributes)
          # Use Ruby 3.2+ data class when available
          data(*attributes)
        end
      end
    end
    
    # Fallback for older Ruby versions
    class FallbackData
      def initialize(**kwargs)
        kwargs.each { |key, value| instance_variable_set("@#{key}", value) }
        freeze
      end
      
      def freeze
        super
        self.class.instance_methods(false).each { |m| method(m).freeze }
      end
    end
  end
end
```

#### 8.3.2 Enhanced Pattern Matching

```ruby
# lib/zai/utils/response_parser.rb
module Zai
  module Utils
    class ResponseParser
      def self.parse_chat_completion(response)
        if Zai::Compatibility.supports_enhanced_pattern_matching?
          case response
          in { id:, model:, choices: [{ message: { content:, role: } }], usage: }
            Models::ChatCompletionResponse.new(
              id: id,
              model: model,
              choices: [
                Models::ChatChoice.new(
                  message: Models::ChatMessage.new(content: content, role: role),
                  finish_reason: nil
                )
              ],
              usage: usage
            )
          in { error: { message:, type:, code: } }
            raise Zai::APIError.new(message, type: type, code: code)
          else
            raise Zai::Error, "Unexpected response format"
          end
        else
          # Fallback for older Ruby versions
          legacy_parse(response)
        end
      end
    end
  end
end
```

### 8.4 Performance Optimizations for Ruby 3.2+

#### 8.4.1 Memory Management

```ruby
# lib/zai/utils/memory_manager.rb
module Zai
  module Utils
    class MemoryManager
      def self.optimize_for_ruby_32
        if Zai::Compatibility.ruby_32_plus?
          # Enable garbage collection tuning
          GC.opts[:minor_gc_tuning] = {
            :full_mark_threshold => 1.0,
            :step_size => 1.1
          }
        end
      end
      
      def self.cleanup_resources
        # Explicit cleanup for large responses
        if defined?(GC) && GC.respond_to?(:compact)
          GC.compact
        end
      end
    end
  end
end
```

#### 8.4.2 YJIT Optimizations

```ruby
# lib/zai/client.rb
module Zai
  class Client
    def initialize(**options)
      @configuration = Configuration.new(options)
      validate_configuration!
      
      # Enable YJIT optimizations in Ruby 3.2+
      if Zai::Compatibility.ruby_32_plus? && defined?(RubyVM::YJIT)
        RubyVM::YJIT.enable
      end
    end
    
    # ... rest of the implementation ...
  end
end
```

### 8.5 JRuby 10.0.4.0+ Specific Optimizations

#### 8.5.1 Concurrent Processing

```ruby
# lib/zai/jruby/concurrent_client.rb
module Zai
  module JRuby
    class ConcurrentClient < Client
      def initialize(**options)
        super(**options)
        
        if Zai::Compatibility.jruby?
          require 'concurrent-ruby'
          @executor = Concurrent::ThreadPoolExecutor.new(
            min_threads: 2,
            max_threads: [4, Concurrent.processor_count].min
          )
        end
      end
      
      def parallel_completions(requests, &block)
        return super(requests) unless Zai::Compatibility.jruby?
        
        futures = requests.map do |request|
          Concurrent::Future.execute(executor: @executor) do
            chat.completions(request)
          end
        end
        
        results = futures.map(&:value)
        block.call(results) if block_given?
        results
      ensure
        @executor&.shutdown
        @executor&.wait_for_termination(30)
      end
    end
  end
end
```

#### 8.5.2 Java Integration

```ruby
# lib/zai/jruby/java_integration.rb
module Zai
  module JRuby
    module JavaIntegration
      def self.create_http_client(base_url)
        if Zai::Compatibility.jruby?
          require 'java'
          
          import 'java.net.http.HttpClient'
          import 'java.net.http.HttpRequest'
          import 'java.net.http.HttpResponse'
          import 'java.time.Duration'
          
          client = HttpClient.newBuilder
            .connectTimeout(Duration.ofSeconds(30))
            .version(HttpClient.Version.HTTP_2)
            .build
            
          JRubyHttpClient.new(client, base_url)
        else
          raise "Java integration is only available on JRuby"
        end
      end
      
      class JRubyHttpClient
        def initialize(java_client, base_url)
          @client = java_client
          @base_url = base_url
        end
        
        def post(path, body)
          request = HttpRequest.newBuilder
            .uri(java.net.URI.new("#{@base_url}#{path}"))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(body.to_json))
            .build
          
          response = @client.send(request, HttpResponse.BodyHandlers.ofString)
          JSON.parse(response.body)
        end
      end
    end
  end
end
```

### 8.6 CI/CD Configuration for Multiple Ruby Versions

```yaml
# .github/workflows/test.yml
name: Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test-matrix:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby-version: ['3.2.8', '3.3.0']
        include:
          - ruby-version: '3.2.8'
            gemfile: gemfiles/ruby_32.gemfile
          - ruby-version: '3.3.0'
            gemfile: gemfiles/ruby_33.gemfile
          - ruby-version: 'jruby-10.0.4.0'
            gemfile: gemfiles/jruby.gemfile
    
    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby-version }}
          bundler-cache: true
          cache-version: 1
      - name: Run RSpec tests
        run: bundle exec rake spec
      
      - name: Run RSpec unit tests
        run: bundle exec rake spec_unit
      
      - name: Run RSpec integration tests
        run: bundle exec rake spec_integration
      
      # Ruby 3.2+ specific tests
      - name: Run Ruby 3.2+ specific tests
        if: matrix.ruby-version == '3.2.8' || matrix.ruby-version == '3.3.0'
        run: bundle exec rake spec_performance
      
      # JRuby specific tests
      - name: Run JRuby specific tests
        if: matrix.ruby-version == 'jruby-10.0.4.0'
        run: bundle exec rake spec_integration
```

### 8.7 Gemfiles for Different Ruby Versions

```ruby
# gemfiles/ruby_32.gemfile
source "https://rubygems.org"
ruby ">= 3.2.8"

gemspec path: ".."

# Ruby 3.2+ specific gems
gem "benchmark", "~> 0.2"
gem "memory_profiler", "~> 1.0"

group :development, :test do
  gem "rake", "~> 13.0"
  gem "rspec", "~> 3.12"
  gem "vcr", "~> 6.2"
  gem "webmock", "~> 3.19"
end
```

```ruby
# gemfiles/ruby_33.gemfile
source "https://rubygems.org"
ruby ">= 3.3.0"

gemspec path: ".."

# Ruby 3.3+ specific gems
gem "benchmark", "~> 0.2"
gem "memory_profiler", "~> 1.0"

group :development, :test do
  gem "rake", "~> 13.0"
  gem "rspec", "~> 3.12"
  gem "vcr", "~> 6.2"
  gem "webmock", "~> 3.19"
end
```

```ruby
# gemfiles/jruby.gemfile
source "https://rubygems.org"
ruby "~> 10.0.4.0"

gemspec path: ".."

# JRuby-specific gems
gem "concurrent-ruby", "~> 1.2"

group :development, :test do
  gem "rake", "~> 13.0"
  gem "rspec", "~> 3.12"
  gem "vcr", "~> 6.2"
  gem "webmock", "~> 3.19"
  
  # JRuby debugging
  gem "debase"
  gem "ruby-debug-ide"
end
```

## 8.8 JRuby Compatibility

### 8.8.1 Conditional Dependencies

```ruby
# lib/zai.rb
require 'zai/version'

# Core dependencies
require 'httparty'
require 'json'
require 'dry-struct'
require 'dry-validation'

# JRuby-specific optimizations
if RUBY_ENGINE == 'jruby'
  require 'concurrent-ruby'
  require 'concurrent-ruby-ext'
end

# Main SDK components
require 'zai/client'
require 'zai/configuration'
require 'zai/error'
```

### 8.2 HTTP Client Optimization for JRuby

```ruby
# lib/zai/http_connection.rb
module Zai
  class HTTPConnection
    # ... existing code ...
    
    private
    
    def build_http_client
      if RUBY_ENGINE == 'jruby'
        # JRuby-optimized client with persistent connections
        HTTParty.persistent(configuration.base_url) do |http|
          http.timeout configuration.timeout
          http.open_timeout configuration.timeout / 2
          http.headers.update(build_headers)
          
          # JRuby-specific optimizations
          http.ssl_version :TLSv1_2
          http.keep_alive true
        end
      else
        # Standard MRI client
        HTTParty.persistent(configuration.base_url) do |http|
          http.timeout configuration.timeout
          http.open_timeout configuration.timeout / 2
          http.headers.update(build_headers)
        end
      end
    end
  end
end
```

## 9. Performance Optimizations

### 9.1 Connection Pooling

```ruby
# lib/zai/utils/connection_pool.rb
require 'connection_pool'

module Zai
  module Utils
    class ConnectionPool
      def initialize(size: 5, &block)
        @pool = ::ConnectionPool.new(size: size, &block)
      end
      
      def with(&block)
        @pool.with(&block)
      end
    end
  end
end
```

### 9.2 Response Caching

```ruby
# lib/zai/utils/response_cache.rb
module Zai
  module Utils
    class ResponseCache
      def initialize(cache: nil, ttl: 300)
        @cache = cache || MemoryCache.new
        @ttl = ttl
      end
      
      def get(key)
        @cache.get(key)
      end
      
      def set(key, value)
        @cache.set(key, value, ttl: @ttl)
      end
      
      def fetch(key, &block)
        get(key) || set(key, block.call)
      end
      
      def key_for(method, params)
        "#{method}:#{Digest::MD5.hexdigest(params.to_json)}"
      end
    end
  end
end
```

## 10. Rails Integration

### 10.1 Railtie Configuration

```ruby
# lib/zai/rails.rb
require 'zai'
require 'rails'

module Zai
  class Railtie < Rails::Railtie
    config.zai = ActiveSupport::OrderedOptions.new
    
    initializer "zai.configure" do |app|
      Zai.configure do |config|
        config.api_key = app.config.zai.api_key || ENV["ZAI_API_KEY"]
        config.base_url = app.config.zai.base_url
        config.timeout = app.config.zai.timeout || 30
        config.max_retries = app.config.zai.max_retries || 3
      end
    end
  end
end
```

### 10.2 ActiveJob Integration

```ruby
# lib/zai/integrations/active_job.rb
module Zai
  module Integrations
    module ActiveJob
      def generate_chat_completion(messages, model: "glm-5", **options)
        client = Zai.client
        response = client.chat.completions(
          messages: messages,
          model: model,
          **options
        )
        response.first_message
      end
    end
  end
end

# Usage in Rails job:
# class GenerateJob < ApplicationJob
#   include Zai::Integrations::ActiveJob
#   
#   def perform(user_input)
#     response = generate_chat_completion(user_input)
#     # Process response...
#   end
# end
```

## Conclusion

This comprehensive implementation plan provides a detailed roadmap for creating the Z.ai Ruby SDK. The plan focuses on:

1. **Ruby Version Requirements**: Support for Ruby >= 3.2.8 and JRuby >= 10.0.4.0 with version-specific optimizations
2. **Ruby 3.2+ Features**: Leveraging YJIT compiler, data classes, and enhanced pattern matching for improved performance
3. **JRuby Optimizations**: True parallelism and Java integration for high-throughput scenarios
4. **Idiomatic Ruby Code**: Following Ruby conventions and community best practices
5. **Clean Architecture**: Modular, maintainable design with clear separation of concerns
6. **Comprehensive Testing**: Full test coverage across Ruby 3.2.8, 3.3.x, and JRuby 10.0.4.0+
7. **Documentation**: Complete API documentation with version-specific examples and migration guides
8. **Extensibility**: Support for future features and multi-platform compatibility
9. **Developer Experience**: Simple, intuitive API design that mirrors Python SDK functionality

The implementation team can follow this plan directly, with concrete code examples and architectural decisions provided for each component. The phased approach allows for iterative development, with each phase building upon previous work and delivering value incrementally.