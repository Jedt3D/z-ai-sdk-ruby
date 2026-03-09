# Z.ai Ruby SDK OpenSpec Specification

## 1. Project Overview

### 1.1 Project Name
`zai-ruby-sdk` - A Ruby gem providing bindings for Z.ai's AI services

### 1.2 Purpose
Create a Ruby SDK that provides idiomatic Ruby interfaces to Z.ai's AI services, modeling after their Python SDK while following Ruby conventions and best practices.

### 1.3 Scope
- Client for Z.ai API communication
- Support for chat completions (including streaming)
- Support for embeddings, image generation, video generation
- Authentication with API key and JWT tokens
- Error handling and retries
- Ruby and JRuby compatibility

## 2. Architecture Design

### 2.1 Module Structure
```
Zai
├── Client                # Main client class
├── Configuration         # Configuration management
├── Error                 # Error classes
├── API
│   ├── Chat             # Chat completions API
│   ├── Embeddings       # Text embeddings API
│   ├── Images           # Image generation API
│   ├── Videos           # Video generation API
│   ├── Audio            # Audio processing API
│   ├── Files            # File management API
│   └── Assistants       # Assistant API
├── Models                # Response and request models
│   ├── Chat
│   ├── Embeddings
│   └── ...
└── Utils                # Utility classes
    ├── JWT              # JWT token handling
    └── HTTP             # HTTP client wrapper
```

### 2.2 Dependencies Analysis
| Python Dependency | Ruby Equivalent | Purpose |
|-------------------|----------------|---------|
| httpx | `httparty` or `faraday` | HTTP client |
| pydantic | `dry-struct` or `active_model_attributes` | Data validation/serialization |
| typing-extensions | Built-in with RBS/TypeProf | Type hints |
| cachetools | `redis` or memory cache | Caching utilities |
| pyjwt | `jwt` gem | JWT handling |

### 2.3 Client Class Design
```ruby
module Zai
  class Client
    attr_reader :api_key, :base_url, :configuration
    
    def initialize(api_key: nil, base_url: nil, **options)
      # Initialize with configuration
    end
    
    # API resources
    def chat
      @chat ||= API::Chat.new(self)
    end
    
    def embeddings
      @embeddings ||= API::Embeddings.new(self)
    end
    
    # ... other API resources
    
    private
    
    def connection
      # HTTP client instance
    end
  end
end
```

## 3. Core API Components

### 3.1 Chat API
```ruby
module Zai
  module API
    class Chat
      def initialize(client)
        @client = client
      end
      
      def completions(messages:, model: nil, **options)
        # Non-streaming chat completion
      end
      
      def stream(messages:, model: nil, **options)
        # Streaming chat completion
      end
    end
  end
end
```

### 3.2 Configuration Management
```ruby
module Zai
  class Configuration
    attr_accessor :api_key, :base_url, :timeout, :max_retries, :disable_token_cache
    
    def initialize
      @base_url = default_base_url
      @timeout = 30
      @max_retries = 3
      @disable_token_cache = true
    end
    
    private
    
    def default_base_url
      # Determine based on client type (Zai vs ZhipuAi)
    end
  end
end
```

## 4. Authentication Strategy

### 4.1 API Key Authentication
```ruby
module Zai
  module Auth
    class ApiKeyAuth
      def initialize(api_key, source_channel: 'ruby-sdk')
        @api_key = api_key
        @source_channel = source_channel
      end
      
      def headers
        {
          'Authorization' => "Bearer #{@api_key}",
          'x-source-channel' => @source_channel
        }
      end
    end
  end
end
```

### 4.2 JWT Token Authentication
```ruby
module Zai
  module Auth
    class JwtAuth
      def initialize(api_key, cache: nil, ttl: 3600)
        @api_key = api_key
        @cache = cache
        @ttl = ttl
      end
      
      def headers
        token = cached_token || generate_token
        {
          'Authorization' => "Bearer #{token}",
          'x-source-channel' => @source_channel
        }
      end
      
      private
      
      def generate_token
        # Generate JWT token using ruby-jwt
      end
    end
  end
end
```

## 5. Error Handling

### 5.1 Error Hierarchy
```ruby
module Zai
  class Error < StandardError; end
  
  class APIError < Error
    attr_reader :status_code, :response_body
    
    def initialize(message, status_code: nil, response_body: nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end
  
  class AuthenticationError < APIError; end
  class RateLimitError < APIError; end
  class TimeoutError < APIError; end
  class ServerError < APIError; end
end
```

## 6. Data Models

### 6.1 Request/Response Models
```ruby
module Zai
  module Models
    class ChatMessage
      include ActiveModel::Attributes
      include ActiveModel::Validations
      
      attribute :role, :string
      attribute :content, :string
      attribute :name, :string
      
      validates :role, presence: true, inclusion: { in: %w[system user assistant] }
      validates :content, presence: true
    end
    
    class ChatCompletionResponse
      include ActiveModel::Attributes
      
      attribute :id, :string
      attribute :object, :string
      attribute :created, :integer
      attribute :model, :string
      attribute :choices, array: true
      attribute :usage, default: -> { Models::Usage.new }
    end
  end
end
```

## 7. Ruby-Specific Considerations

### 7.1 Async Support
- Consider `async` gem for async operations
- Support Ruby's `Enumerator` for streaming responses

### 7.2 Type Safety
- Use RBS (Ruby Signature) for type definitions
- Consider `dry-struct` for type-safe models

### 7.3 Configuration Patterns
- Follow Ruby conventions for configuration (YAML files, environment variables)
- Support both block-based and hash-based configuration

## 8. Testing Strategy

### 8.1 Unit Tests
- Test all API endpoints
- Mock HTTP responses using VCR
- Test error handling scenarios

### 8.2 Integration Tests
- Test against Z.ai test API (if available)
- Verify authentication flow
- Test streaming functionality

### 8.3 Performance Tests
- Benchmark request/response times
- Test memory usage for large payloads

## 9. Release Strategy

### 9.1 Version Control
- Follow semantic versioning
- Use GitHub releases

### 9.2 RubyGems Publication
- Automated release via GitHub Actions
- Support multiple Ruby versions (2.7+, 3.0+, JRuby)

## 10. Documentation Strategy

### 10.1 API Documentation
- YARD documentation for all public methods
- Examples in docstrings

### 10.2 Guides
- Quick start guide
- Migration guide from Python SDK
- Best practices guide

## 11. Open Questions

1. Should we use `httparty` or `faraday` as HTTP client? (faraday offers more middleware support)
2. Should we support Rails-specific integrations (ActiveJob, ActiveStorage)?
3. How should we handle streaming in Ruby? (Enumerator vs custom iterator)
4. Should we provide both sync and async interfaces?
5. How should we handle large file uploads? (direct upload vs streaming)

## 12. Minimum Viable Product for v1.0

### Core Features:
- [ ] Basic chat completions (non-streaming)
- [ ] Authentication (API key)
- [ ] Error handling
- [ ] Basic configuration

### Additional Features:
- [ ] Streaming chat completions
- [ ] JWT token authentication
- [ ] Embeddings API
- [ ] Retry mechanism
- [ ] Type safety (RBS signatures)

### Future Considerations:
- [ ] All other APIs (images, videos, audio, files)
- [ ] Async support
- [ ] Rails integrations
- [ ] Advanced caching