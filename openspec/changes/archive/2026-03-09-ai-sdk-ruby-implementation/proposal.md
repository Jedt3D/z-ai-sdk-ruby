## Why

Create a comprehensive Ruby SDK for Z.ai AI services to enable Ruby developers to easily integrate AI capabilities into their applications. The SDK provides idiomatic Ruby bindings for chat completions, embeddings, images, and files APIs with proper authentication, error handling, and configuration management.

## What Changes

- Implement a complete Ruby gem structure with proper namespace organization
- Create core SDK components including client, configuration, and authentication
- Implement four main API resources: Chat, Embeddings, Images, and Files
- Add comprehensive error handling and retry logic
- Provide streaming support for real-time responses
- Include JWT token caching for improved performance
- Add Rails integration support
- Create extensive test suite with 100+ test cases
- Provide Docker testing environments for Ruby and JRuby
- Write comprehensive documentation and examples

## Capabilities

### New Capabilities

- `chat-completions`: Text generation with streaming support, message handling, and conversation management
- `embeddings`: Text vector embedding generation with similarity calculation capabilities  
- `images`: Image generation from text prompts with various sizes and formats
- `files`: File upload, management, and lifecycle operations for fine-tuning and batch processing
- `auth-jwt`: JWT token generation and caching for API authentication
- `http-client`: HTTP client with retry logic, timeout handling, and proxy support
- `error-handling`: Comprehensive error handling for API responses and network issues
- `configuration`: Flexible configuration management with environment variables and instance overrides
- `rails-integration`: Rails-specific integration with generators and ActiveJob support

### Modified Capabilities

None - this is a new SDK implementation.

## Impact

- Provides Ruby developers with first-class access to Z.ai AI services
- Establishes proper Ruby gem structure following community best practices
- Enables both synchronous and asynchronous operation patterns
- Supports both Ruby 3.2.8 and JRuby 10.0.4.0 environments
- Includes comprehensive testing infrastructure for CI/CD pipelines
- Provides Rails integration for seamless adoption in Ruby on Rails applications