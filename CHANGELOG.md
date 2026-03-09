# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial implementation of Z.ai Ruby SDK
- Core HTTP client wrapper with retry logic
- Authentication system with JWT token caching
- Chat completions API with streaming support
- Data models using Dry::Struct for type safety
- Comprehensive error handling hierarchy
- Configuration system with environment variable support
- RSpec testing framework setup
- Basic examples and documentation
- Support for Ruby >= 3.2.8 and JRuby >= 10.0.4.0

### Features
- **Chat API**
  - Chat completions with multiple models
  - Streaming response support
  - Multimodal messages (text and images)
  - Function calling support
  - Conversation context management

- **Embeddings API**
  - Text embeddings for single and multiple texts
  - Semantic similarity calculations
  - Document search capabilities
  - Support for various embedding models

- **Images API**
  - Image generation from text prompts
  - Multiple image sizes (256x256, 512x512, 1024x1024, etc.)
  - Batch image generation
  - URL and base64 response formats
  - Multiple models support (cogview-3, etc.)

- **Files API**
  - File upload for fine-tuning and other purposes
  - File listing and retrieval
  - File content download
  - File deletion
  - Support for multiple purposes (fine-tune, assistants, batch, vision)

- **Authentication**
  - API key authentication
  - JWT token generation and caching
  - Automatic token refresh

- **HTTP Client**
  - Retry mechanism with exponential backoff
  - Configurable timeouts
  - Proxy support
  - Request/response logging
  - Sensitive data filtering in logs

- **Error Handling**
  - Specific error types for different HTTP status codes
  - Detailed error context (message, code, status, body)
  - Validation errors
  - Authentication errors
  - Rate limit errors

- **Configuration**
  - Global configuration
  - Per-client configuration
  - Environment variable support
  - Flexible timeout settings

- **Testing**
  - RSpec test suite
  - WebMock for HTTP stubbing
  - VCR for recording HTTP interactions
  - FactoryBot for test data
  - SimpleCov for coverage reporting

- **Documentation**
  - Comprehensive README
  - Code examples
  - API reference
  - Usage examples

### Dependencies
- httparty ~> 0.22 (HTTP client)
- dry-struct ~> 1.6 (Type-safe models)
- dry-validation ~> 1.10 (Validation)
- jwt ~> 2.9 (JWT tokens)
- logger ~> 1.6 (Logging)

### Development Dependencies
- rspec ~> 3.13 (Testing)
- webmock ~> 3.24 (HTTP mocking)
- vcr ~> 6.3 (HTTP recording)
- simplecov ~> 0.22 (Coverage)
- factory_bot ~> 6.5 (Test data)
- rubocop ~> 1.69 (Linting)
- yard ~> 0.9 (Documentation)

## [0.1.0] - 2024-XX-XX

### Added
- Initial release
- Basic chat completions API
- Authentication with JWT tokens
- Error handling
- Configuration system
- Basic tests and documentation

[Unreleased]: https://github.com/zai-org/z-ai-sdk-ruby/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/zai-org/z-ai-sdk-ruby/releases/tag/v0.1.0
