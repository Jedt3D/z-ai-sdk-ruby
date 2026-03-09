# Z.ai Ruby SDK Project Structure

```
zai-ruby-sdk/
├── Gemfile                    # Ruby dependencies
├── gemspec                    # Gem specification
├── README.md                  # Documentation
├── CHANGELOG.md               # Version history
├── LICENSE                    # MIT License
├── Rakefile                   # Build tasks
├── ruby-version-requirements.md  # Ruby version compatibility guide
├── .github/
│   └── workflows/
│       ├── ci.yml            # GitHub Actions CI
│       └── release.yml       # Release automation
├── lib/                       # Source code
│   ├── zai.rb                # Main entry point
│   ├── zai/
│   │   ├── version.rb        # Version information
│   │   ├── client.rb         # Main client class
│   │   ├── configuration.rb  # Configuration management
│   │   ├── compatibility.rb  # Ruby version compatibility
│   │   ├── error.rb          # Error definitions
│   │   ├── http_connection.rb # HTTP client wrapper
│   │   ├── concerns/         # Shared modules
│   │   │   └── retryable.rb  # Retry logic
│   │   ├── auth/             # Authentication modules
│   │   │   ├── base.rb       # Base auth class
│   │   │   ├── api_key_auth.rb
│   │   │   └── jwt_auth.rb
│   │   ├── api/              # API resources
│   │   │   ├── base.rb       # Base API class
│   │   │   ├── chat.rb       # Chat completions
│   │   │   ├── embeddings.rb # Text embeddings
│   │   │   ├── images.rb     # Image generation
│   │   │   ├── videos.rb     # Video generation
│   │   │   ├── audio.rb      # Audio processing
│   │   │   ├── files.rb      # File management
│   │   │   └── assistants.rb # Assistant API
│   │   ├── models/           # Data models
│   │   │   ├── base.rb       # Base model class
│   │   │   ├── chat/
│   │   │   │   ├── message.rb
│   │   │   │   ├── completion_response.rb
│   │   │   │   └── choice.rb
│   │   │   ├── embeddings/
│   │   │   │   ├── request.rb
│   │   │   │   └── response.rb
│   │   │   └── shared/
│   │   │       └── usage.rb
│   │   └── utils/            # Utilities
│   │       ├── cache/
│   │       │   ├── memory_cache.rb
│   │       │   └── redis_cache.rb
│   │       ├── jwt.rb        # JWT utilities
│   │       └── memory_manager.rb  # Ruby 3.2+ memory optimization
│   └── jruby/                # JRuby-specific modules
│       ├── concurrent_client.rb  # Parallel processing
│       └── java_integration.rb    # Java library integration
├── spec/                      # Tests
│   ├── spec_helper.rb        # Test configuration
│   ├── support/              # Test support files
│   │   ├── vcr_setup.rb      # VCR for HTTP mocking
│   │   └── fixtures/        # Test data
│   ├── zai/
│   │   ├── client_spec.rb
│   │   ├── configuration_spec.rb
│   │   ├── api/
│   │   │   └── chat_spec.rb
│   │   └── models/
│   │       └── chat_spec.rb
├── sig/                       # RBS type signatures
│   ├── zai.rbs              # Main type definitions
│   └── zai/
│       ├── client.rbs
│       ├── configuration.rbs
│       └── api/
│           └── chat.rbs
└── examples/                  # Usage examples
    ├── quick_start.rb
    ├── streaming_chat.rb
    ├── embeddings.rb
    └── custom_configuration.rb
```

## Key Files Overview

### lib/zai.rb
Main entry point that sets up the SDK and provides convenience methods:

```ruby
require "zai/version"
require "zai/client"

module Zai
  # Factory methods for different client types
  def self.overseas_client(**options)
    # Returns client for overseas API
  end
  
  def self.china_client(**options)
    # Returns client for China API
  end
end

# Aliases for Python SDK compatibility
ZaiClient = Zai.method(:overseas_client)
ZhipuAiClient = Zai.method(:china_client)
```

### lib/zai/client.rb
Core client class that orchestrates all API interactions:

```ruby
module Zai
  class Client
    attr_reader :configuration
    
    def initialize(**options)
      @configuration = Configuration.new(options)
    end
    
    # API resources
    def chat
      @chat ||= API::Chat.new(self)
    end
    
    def embeddings
      @embeddings ||= API::Embeddings.new(self)
    end
    
    # Connection method
    def connection
      @connection ||= HTTPConnection.new(configuration)
    end
  end
end
```

### Gem Dependencies to Consider

#### Core Dependencies
- `httparty` (>= 0.21.0) - HTTP client
- `jwt` (>= 2.7.0) - JWT token handling
- `dry-struct` (>= 1.6.0) - Type-safe data structures
- `dry-validation` (>= 1.9.0) - Input validation

#### Development Dependencies
- `rspec` (>= 3.12) - Testing framework
- `vcr` (>= 6.0) - HTTP request recording
- `webmock` (>= 3.18) - HTTP stubbing
- `rubocop` (>= 1.50) - Code linting
- `rbs` (>= 2.0) - Type signatures
- `yard` (>= 0.9) - Documentation generation

#### Optional Dependencies
- `redis` (>= 5.0) - For distributed caching
- `async` (>= 2.0) - For async operations

## Implementation Phases

1. **Phase 1**: Core infrastructure (Client, Configuration, HTTP layer)
2. **Phase 2**: Authentication and error handling
3. **Phase 3**: Chat API implementation (MVP)
4. **Phase 4**: Additional APIs (embeddings, images, etc.)
5. **Phase 5**: Advanced features (async, caching, optimizations)
6. **Phase 6**: Documentation and examples

## Testing Strategy

### Unit Tests
- Test all classes and methods in isolation
- Mock HTTP responses with VCR
- Verify error handling scenarios

### Integration Tests
- Test against Z.ai test endpoints (if available)
- Verify authentication flow
- Test streaming functionality

### Performance Tests
- Benchmark request/response times
- Memory usage tests for large payloads
- Concurrent request handling

## Release Process

1. Semantic versioning (MAJOR.MINOR.PATCH)
2. Automated tests on all supported Ruby versions
3. GitHub Actions for CI/CD
4. Automatic RubyGems release on tag push
5. GitHub releases with changelog

## Documentation Plan

### Code Documentation
- YARD comments for all public APIs
- Type signatures with RBS
- Inline examples in documentation

### User Documentation
- README with quick start guide
- API documentation (generated from YARD)
- Examples directory with common use cases
- Migration guide from Python SDK

## Ruby Version Support

- Ruby 2.7+
- Ruby 3.0+
- Ruby 3.1+
- JRuby 9.4+

(Consider dropping older versions as they approach EOL)