# Z.ai Ruby SDK Documentation Plan

## Executive Summary

This documentation plan provides a comprehensive strategy for creating, maintaining, and evolving the documentation for the Z.ai Ruby SDK. The plan focuses on making the SDK accessible to Ruby developers while ensuring documentation stays in sync with the codebase and follows Ruby community standards.

## Ruby Version Requirements

The Z.ai Ruby SDK supports:
- **Ruby >= 3.2.8** (minimum version)
- **JRuby >= 10.0.4.0** (minimum version)

These requirements ensure compatibility with modern Ruby features while maintaining broad support across different Ruby implementations.

## 1. Ruby Version Requirements Documentation

### 1.1 Supported Ruby Versions

#### 1.1.1 Ruby Support Matrix

| Ruby Version | Status | End of Life | Notes |
|--------------|--------|-------------|-------|
| 3.2.8+       | ✅ Supported | TBA | Minimum supported version |
| 3.3.0+       | ✅ Supported | Current | Recommended version |
| 3.1.x        | ❌ Not Supported | 2025-03-31 | Below minimum requirement |
| 3.0.x        | ❌ Not Supported | 2024-03-31 | Below minimum requirement |

#### 1.1.2 JRuby Support Matrix

| JRuby Version | Status | End of Life | Notes |
|---------------|--------|-------------|-------|
| 10.0.4.0+     | ✅ Supported | TBA | Minimum supported version |
| 9.4.x         | ❌ Not Supported | 2024-12-31 | Below minimum requirement |

### 1.2 Ruby Version-Specific Features

#### 1.2.1 Ruby 3.2+ Features

The SDK leverages Ruby 3.2+ features when available:

1. **Data Classes**: Using `data` keyword for immutable structs
2. **Enhanced Pattern Matching**: Improved response parsing
3. **Performance Improvements**: YJIT optimizations and memory enhancements
4. **Anonymous Method Parameters**: Cleaner method signatures

#### 1.2.2 JRuby-Specific Optimizations

On JRuby, the SDK provides:

1. **True Parallelism**: Concurrent processing capabilities
2. **Java Integration**: Access to Java libraries for performance
3. **Native Threads**: Improved concurrency for batch operations

### 1.3 Installation Guide by Ruby Version

#### 1.3.1 Standard Ruby Installation

```bash
# Verify Ruby version (must be >= 3.2.8)
ruby --version

# Install the gem
gem install zai-ruby-sdk

# Or add to Gemfile
echo "gem 'zai-ruby-sdk'" >> Gemfile
bundle install
```

#### 1.3.2 JRuby Installation

```bash
# Install JRuby using rbenv
rbenv install jruby-10.0.4.0
rbenv local jruby-10.0.4.0

# Verify JRuby version
ruby --version

# Install with JRuby-specific optimizations
jruby -S gem install zai-ruby-sdk
```

### 1.4 Migration Guide for Ruby 3.0/3.1 Users

If you're currently using Ruby 3.0 or 3.1:

1. **Upgrade Ruby**: Upgrade to Ruby 3.2.8 or later
2. **Review Dependencies**: Ensure all dependencies are compatible
3. **Test Application**: Run your test suite after upgrading
4. **Update CI/CD**: Update your CI pipelines to use Ruby 3.2.8+

### 1.5 Troubleshooting Ruby Version Issues

#### 1.5.1 Common Issues and Solutions

**Issue**: `Gem::InstallError: zai-ruby-sdk requires Ruby version >= 3.2.8`

**Solution**:
```bash
# Using rbenv
rbenv install 3.2.8
rbenv local 3.2.8

# Using rvm
rvm install 3.2.8
rvm use 3.2.8

# Using system package manager (Ubuntu/Debian)
sudo apt-get install ruby3.2
```

**Issue**: JRuby performance problems

**Solution**:
```ruby
# Enable JRuby optimizations
require 'zai'
Zai::JRuby.optimize_performance!

# Or configure manually
if defined?(JRUBY_VERSION)
  java.lang.System.setProperty("jruby.thread.pool.enabled", "true")
  java.lang.System.setProperty("jruby.compile.invokedynamic", "true")
end
```

## 2. Documentation Structure

### 2.1 README.md Structure

```markdown
# Z.ai Ruby SDK

[![Gem Version](https://badge.fury.io/rb/zai-ruby-sdk.svg)](https://badge.fury.io/rb/zai-ruby-sdk)
[![Build Status](https://github.com/z-ai-ruby/sdk/workflows/CI/badge.svg)](https://github.com/z-ai-ruby/sdk/actions)
[![Documentation](https://yardoc.org/badges/github/z-ai-ruby/sdk.svg)](https://yardoc.org/github/z-ai-ruby/sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D3.2.8-red.svg)](https://www.ruby-lang.org/)
[![JRuby Version](https://img.shields.io/badge/jruby-%3E%3D10.0.4.0-red.svg)](https://www.jruby.org/)

The official Ruby SDK for Z.ai's AI services, providing idiomatic Ruby interfaces to powerful AI models including GLM language models, embeddings, image generation, and more.

## Requirements

- **Ruby >= 3.2.8** (minimum supported version)
- **JRuby >= 10.0.4.0** (for JRuby users)
- **Ruby 3.3.x** (recommended for best performance)

## ⚡ Quick Start

### Installation

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

### Basic Usage

```ruby
require 'zai'

# Initialize client for overseas API
client = Zai.overseas_client(api_key: "your-api-key")

# Simple chat completion
response = client.chat.completions(
  messages: "Hello, world!",
  model: "glm-5"
)

puts response.first_message
```

## 🚀 Features

- 🎯 **Simple, idiomatic Ruby interface** - Designed by Ruby developers for Ruby developers
- 💬 **Chat completions with streaming support** - Real-time response generation
- 🔍 **Text embeddings** - Convert text to vector representations
- 🖼️ **Image generation** - Create images from text descriptions
- 🎥 **Video generation** - Generate video content
- 🔊 **Audio processing** - Speech-to-text and text-to-speech
- 📁 **File management** - Upload and manage files
- 🤖 **Assistant API** - Build custom AI assistants
- 🔐 **Robust authentication** - API key and JWT token support
- 🔄 **Automatic retry mechanism** - Built-in resilience
- 🧪 **Comprehensive test coverage** - Reliable and well-tested
- 📖 **Full API documentation** - Complete reference guide

## 📖 Documentation

- [API Reference](https://rubydoc.info/gems/zai-ruby-sdk) - Complete API documentation
- [Examples](./examples/) - Practical usage examples
- [Guides](./guides/) - In-depth tutorials and guides
- [Migration from Python SDK](./guides/migration.md) - For Python developers

## 🛠️ Installation & Setup

### Configuration Options

```ruby
client = Zai.client(
  api_key: "your-key",
  base_url: "https://api.z.ai/api/paas/v4",  # or China URL
  timeout: 30,
  max_retries: 3,
  disable_token_cache: false
)
```

### Environment Variables

```bash
export ZAI_API_KEY="your-api-key"
export ZAI_BASE_URL="https://api.z.ai/api/paas/v4"
export ZAI_TIMEOUT=30
```

## 💡 Common Use Cases

### Chat Completions

```ruby
# Simple completion
response = client.chat.completions(
  messages: "What is Ruby?",
  model: "glm-5",
  max_tokens: 100
)

# Conversation with context
messages = [
  { role: "system", content: "You are a helpful Ruby expert." },
  { role: "user", content: "What's the difference between Proc and lambda?" },
  { role: "assistant", content: "In Ruby..." },
  { role: "user", content: "Can you give me an example?" }
]
response = client.chat.completions(messages: messages)
```

### Streaming Responses

```ruby
# Block-style streaming (Ruby idiomatic)
client.chat.stream(messages: "Tell me a story") do |chunk|
  print chunk.dig(:choices, 0, :delta, :content)
end

# Enumerator-style (functional)
enum = client.chat.stream(messages: "Explain quantum computing")
enum.each { |chunk| process_chunk(chunk) }
```

### Text Embeddings

```ruby
response = client.embeddings.embeddings(
  input: ["Hello world", "Goodbye world"],
  model: "text-embedding-ada-002"
)

vectors = response.data.map { |item| item.embedding }
```

## 🔧 Advanced Features

### Error Handling

```ruby
begin
  response = client.chat.completions(messages: "Hello")
rescue Zai::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue Zai::RateLimitError => e
  puts "Rate limit exceeded. Please wait."
rescue Zai::APIError => e
  puts "API error (#{e.status_code}): #{e.message}"
end
```

### Custom Configuration

```ruby
# Create a custom client
client = Zai.client do |config|
  config.api_key = "your-key"
  config.base_url = "https://api.z.ai/api/paas/v4"
  config.timeout = 60
  config.max_retries = 5
  config.disable_token_cache = false
  config.source_channel = "my-app"
end
```

## 🏗️ Architecture

The SDK follows a modular architecture:

```
Zai
├── Client           # Main client interface
├── Configuration    # Configuration management
├── API
│   ├── Chat        # Chat completions API
│   ├── Embeddings  # Text embeddings API
│   ├── Images      # Image generation API
│   ├── Videos      # Video generation API
│   ├── Audio       # Audio processing API
│   ├── Files       # File management API
│   └── Assistants  # Assistant API
├── Models          # Data models and types
├── Auth            # Authentication modules
└── Utils           # Utility functions
```

## 🧪 Testing

Run the test suite:

```bash
bundle exec rake spec
```

## 🤝 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/z-ai-ruby/sdk. Please see our [Contributing Guide](./CONTRIBUTING.md) for details.

## 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🆘 Support

- 📖 [Documentation](https://rubydoc.info/gems/zai-ruby-sdk)
- 🐛 [Issue Tracker](https://github.com/z-ai-ruby/sdk/issues)
- 💬 [Discussions](https://github.com/z-ai-ruby/sdk/discussions)

## 🗺️ Roadmap

See our [Roadmap](./ROADMAP.md) for upcoming features and releases.
```

### 1.2 CHANGELOG.md Format

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature descriptions

### Changed
- Changes in existing functionality

### Deprecated
- Features that will be removed in future versions

### Removed
- Features removed in this version

### Fixed
- Bug fixes

### Security
- Security-related changes

## [1.0.0] - 2024-01-15

### Added
- Initial release of Z.ai Ruby SDK
- Chat completions API with streaming support
- Text embeddings API
- Image generation API
- Authentication with API keys and JWT tokens
- Automatic retry mechanism
- Comprehensive error handling
- Full API documentation

## [0.9.0] - 2024-01-01

### Added
- Beta release
- Core chat functionality
- Basic authentication
- Initial documentation
```

### 1.3 API Documentation Format

Using YARD for API documentation with consistent formatting:

```ruby
module Zai
  module API
    # Chat API for generating completions using Z.ai's language models
    #
    # This class provides methods to interact with Z.ai's chat completion API,
    # supporting both synchronous and streaming responses.
    #
    # @example Simple completion
    #   client = Zai.overseas_client(api_key: "your-key")
    #   response = client.chat.completions(
    #     messages: "Hello, world!",
    #     model: "glm-5"
    #   )
    #   puts response.first_message
    #
    # @example Streaming completion with block
    #   client.chat.stream(messages: "Count to 10") do |chunk|
    #     print chunk.dig(:choices, 0, :delta, :content)
    #   end
    #
    # @example Conversation with context
    #   messages = [
    #     { role: "system", content: "You are a helpful assistant." },
    #     { role: "user", content: "What is Ruby?" }
    #   ]
    #   response = client.chat.completions(messages: messages)
    #
    # @see https://platform.z.ai/docs/api-reference/chat
    # @since 1.0.0
    class Chat < Base
      # Generate chat completions using Z.ai's language models
      #
      # Creates a model response for the given chat conversation.
      #
      # @param messages [String, Array<Hash, ChatMessage>] The conversation messages
      #   - When String: Creates a single user message
      #   - When Array: Array of message objects with role and content
      # @param model [String] The model to use for completion (default: "glm-5")
      # @param temperature [Float] Sampling temperature between 0.0 and 1.0
      #   - Higher values (like 0.8) make output more random
      #   - Lower values (like 0.2) make output more focused and deterministic
      # @param max_tokens [Integer] Maximum number of tokens to generate
      # @param top_p [Float] Nucleus sampling parameter (0.0 to 1.0)
      # @param stream [Boolean] Whether to stream the response
      # @param stop [String, Array<String>] Sequences where the API will stop generating
      # @param presence_penalty [Float] Penalize new tokens based on presence
      # @param frequency_penalty [Float] Penalize new tokens based on frequency
      # @param options [Hash] Additional options to pass to the API
      #
      # @return [ChatCompletionResponse] The completion response object
      #
      # @raise [InvalidRequestError] When request parameters are invalid
      # @raise [AuthenticationError] When authentication fails
      # @raise [RateLimitError] When rate limit is exceeded
      # @raise [ServerError] When server error occurs
      # @raise [TimeoutError] When request times out
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
      #
      # @example With custom parameters
      #   response = completions(
      #     messages: "Write a poem",
      #     model: "glm-5",
      #     temperature: 0.8,
      #     max_tokens: 200,
      #     top_p: 0.9
      #   )
      #
      # @see https://platform.z.ai/docs/api-reference/chat/create
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
      # @param stop [String, Array<String>] Stop sequences
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
      #
      # @example Collecting all chunks
      #   chunks = []
      #   stream(messages: "Explain Ruby") { |chunk| chunks << chunk }
      #   full_response = chunks.map { |c| c.dig(:choices, 0, :delta, :content) }.join
      #
      # @see https://platform.z.ai/docs/api-reference/chat/create-stream
      def stream(messages:, model: "glm-5", **options, &block)
        # Implementation...
      end
    end
  end
end
```

## 2. Documentation Types

### 2.1 User Documentation

#### 2.1.1 Getting Started Guide (`guides/getting-started.md`)

```markdown
# Getting Started with Z.ai Ruby SDK

This guide will help you get up and running with the Z.ai Ruby SDK quickly.

## Prerequisites

- Ruby 2.7+ (Ruby 3.0+ recommended)
- A Z.ai API key (get one at https://platform.z.ai)

## Installation

### Option 1: Bundler (Recommended)

Add to your Gemfile:
```ruby
gem 'zai-ruby-sdk'
```

Then run:
```bash
bundle install
```

### Option 2: Direct Installation

```bash
gem install zai-ruby-sdk
```

## Your First API Call

### 1. Set up your API key

```ruby
# Option A: Direct initialization
client = Zai.overseas_client(api_key: "your-api-key-here")

# Option B: Environment variable
# Set in your shell:
# export ZAI_API_KEY="your-api-key-here"
client = Zai.overseas_client
```

### 2. Make your first request

```ruby
require 'zai'

client = Zai.overseas_client(api_key: ENV["ZAI_API_KEY"])

response = client.chat.completions(
  messages: "Hello, Z.ai! Tell me something interesting about Ruby.",
  model: "glm-5"
)

puts response.first_message
```

### 3. Run it!

Save the code to `hello_zai.rb` and run:
```bash
ruby hello_zai.rb
```

## Understanding the Response

The `response` object contains:

```ruby
response.id           # Unique identifier for the completion
response.object       # Type of object (usually "chat.completion")
response.created       # Unix timestamp of creation
response.model        # Model used for completion
response.choices       # Array of completion choices
response.usage        # Token usage information

# Get the main response text
response.first_message
```

## Next Steps

- Explore [Chat Completions](./chat-completions.md)
- Learn about [Streaming](./streaming.md)
- Check out [Examples](../examples/)
- Read the [API Reference](https://rubydoc.info/gems/zai-ruby-sdk)
```

#### 2.1.2 Chat Completions Guide (`guides/chat-completions.md`)

```markdown
# Chat Completions Guide

This guide covers using the chat completions API to generate text responses from Z.ai's language models.

## Basics

### Simple Completion

```ruby
response = client.chat.completions(
  messages: "What is Ruby?",
  model: "glm-5"
)

puts response.first_message
```

### Conversations

Maintain context by providing a conversation history:

```ruby
messages = [
  { role: "system", content: "You are a helpful Ruby expert." },
  { role: "user", content: "What's the difference between a class and a module?" },
  { role: "assistant", content: "In Ruby..." },
  { role: "user", content: "Can you show me an example?" }
]

response = client.chat.completions(messages: messages)
puts response.first_message
```

## Parameters

### Temperature

Control randomness in the response (0.0 to 1.0):

```ruby
# More deterministic
response = client.chat.completions(
  messages: "Explain Ruby's modules",
  temperature: 0.2
)

# More creative
response = client.chat.completions(
  messages: "Write a creative story about Ruby",
  temperature: 0.8
)
```

### Max Tokens

Limit response length:

```ruby
response = client.chat.completions(
  messages: "Tell me about Ruby's history",
  max_tokens: 100
)
```

### Top P

Alternative to temperature for nucleus sampling:

```ruby
response = client.chat.completions(
  messages: "Explain metaprogramming in Ruby",
  top_p: 0.9
)
```

## Streaming

Get responses as they're generated:

```ruby
client.chat.stream(messages: "Write a Ruby poem") do |chunk|
  content = chunk.dig(:choices, 0, :delta, :content)
  print content if content
end

# Or with Enumerator
enum = client.chat.stream(messages: "Count to 10")
enum.each { |chunk| print chunk.dig(:choices, 0, :delta, :content) }
```

## Error Handling

```ruby
begin
  response = client.chat.completions(messages: "Hello")
rescue Zai::AuthenticationError => e
  puts "Check your API key: #{e.message}"
rescue Zai::RateLimitError => e
  puts "Rate limit exceeded. Try again later."
rescue Zai::APIError => e
  puts "API error: #{e.message}"
end
```

## Best Practices

1. **Include system messages** for better context
2. **Use appropriate temperature** based on your use case
3. **Handle errors gracefully**
4. **Use streaming** for long responses
5. **Monitor token usage** with response.usage

## Examples

### Ruby Code Generation

```ruby
messages = [
  { role: "system", content: "You are a Ruby expert who writes clean, idiomatic code." },
  { role: "user", content: "Write a Ruby method to validate email addresses." }
]

response = client.chat.completions(
  messages: messages,
  temperature: 0.3
)

puts response.first_message
```

### Documentation Generation

```ruby
messages = [
  { role: "system", content: "You are a technical writer." },
  { role: "user", content: "Write documentation for this Ruby method: def calculate_total(items) items.sum(&:price) end" }
]

response = client.chat.completions(
  messages: messages,
  temperature: 0.2
)
```
```

### 2.2 API Reference Documentation

#### 2.2.1 Client Class Documentation

```ruby
module Zai
  # Main client class for interacting with Z.ai's API
  #
  # The Client is the primary interface to the Z.ai SDK. It manages
  # configuration, authentication, and provides access to all API resources.
  #
  # @example Creating a client
  #   client = Zai.client(
  #     api_key: "your-key",
  #     base_url: "https://api.z.ai/api/paas/v4"
  #   )
  #
  # @example Using factory methods
  #   overseas = Zai.overseas_client(api_key: "key")
  #   china = Zai.china_client(api_key: "key")
  #
  # @see https://platform.z.ai/docs
  class Client
    # Initialize a new client with configuration options
    #
    # @param api_key [String] Your Z.ai API key
    # @param base_url [String] API base URL
    # @param timeout [Integer] Request timeout in seconds (default: 30)
    # @param max_retries [Integer] Maximum retry attempts (default: 3)
    # @param disable_token_cache [Boolean] Disable JWT token caching (default: true)
    # @param source_channel [String] Source channel identifier (default: "ruby-sdk")
    # @param cache [Object] Custom cache implementation (optional)
    #
    # @return [Client] A new client instance
    #
    # @example Basic initialization
    #   client = Zai::Client.new(api_key: "your-key")
    #
    # @example With custom configuration
    #   client = Zai::Client.new(
    #     api_key: "key",
    #     base_url: "https://api.z.ai/api/paas/v4",
    #     timeout: 60,
    #     max_retries: 5
    #   )
    def initialize(**options)
      # Implementation...
    end
    
    # Access the chat API resource
    #
    # @return [API::Chat] Chat API interface
    #
    # @example Simple chat completion
    #   response = client.chat.completions(
    #     messages: "Hello, world!"
    #   )
    def chat
      # Implementation...
    end
    
    # Access the embeddings API resource
    #
    # @return [API::Embeddings] Embeddings API interface
    #
    # @example Create text embeddings
    #   response = client.embeddings.embeddings(
    #     input: "Hello, world!"
    #   )
    def embeddings
      # Implementation...
    end
    
    # Access the images API resource
    #
    # @return [API::Images] Images API interface
    #
    # @example Generate an image
    #   response = client.images.generations(
    #     prompt: "A ruby gem in space",
    #     n: 1,
    #     size: "1024x1024"
    #   )
    def images
      # Implementation...
    end
    
    # Access the videos API resource
    #
    # @return [API::Videos] Videos API interface
    def videos
      # Implementation...
    end
    
    # Access the audio API resource
    #
    # @return [API::Audio] Audio API interface
    def audio
      # Implementation...
    end
    
    # Access the files API resource
    #
    # @return [API::Files] Files API interface
    def files
      # Implementation...
    end
    
    # Access the assistants API resource
    #
    # @return [API::Assistants] Assistants API interface
    def assistants
      # Implementation...
    end
  end
end
```

### 2.3 Developer Documentation

#### 2.3.1 Contributing Guide (`CONTRIBUTING.md`)

```markdown
# Contributing to Z.ai Ruby SDK

Thank you for your interest in contributing to the Z.ai Ruby SDK! This guide will help you get started.

## Development Setup

### Prerequisites

- Ruby 2.7+ (Ruby 3.0+ recommended for development)
- Git
- A text editor or IDE

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/your-username/z-ai-ruby-sdk.git
   cd z-ai-ruby-sdk
   ```

3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/z-ai-ruby/sdk.git
   ```

### Install Dependencies

```bash
bundle install
```

### Run Tests

```bash
bundle exec rake spec
```

### Run Linting

```bash
bundle exec rubocop
```

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Write clear, idiomatic Ruby code
- Follow the existing code style
- Add tests for new functionality
- Update documentation

### 3. Run the Test Suite

```bash
bundle exec rake spec
```

Make sure all tests pass before submitting a pull request.

### 4. Run Static Analysis

```bash
bundle exec rubocop
bundle exec rake typecheck  # If RBS type checking is set up
```

### 5. Commit Your Changes

Follow our commit message convention (see below).

```bash
git commit -m "feat: add new feature description"
```

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

## Code Style

We follow the Ruby community style guidelines enforced by RuboCop:

```bash
bundle exec rubocop -a  # Auto-fix offenses
```

### Naming Conventions

- Use snake_case for methods and variables
- Use PascalCase for classes and modules
- Use SCREAMING_SNAKE_CASE for constants

### Documentation

- Document all public methods with YARD
- Include examples for complex methods
- Keep documentation up to date with code changes

### Testing

- Write tests for all new functionality
- Use descriptive test descriptions
- Mock external dependencies
- Cover edge cases and error conditions

## Commit Message Convention

We use conventional commits:

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `style:` for code style changes
- `refactor:` for code refactoring
- `test:` for adding or updating tests
- `chore:` for maintenance tasks

Examples:
```
feat: add streaming support for chat completions
fix: handle JWT token expiration gracefully
docs: update README with installation instructions
test: add integration tests for embeddings API
```

## Testing

### Unit Tests

Unit tests are located in `spec/zai/`. Run them with:
```bash
bundle exec rspec spec/zai/
```

### Integration Tests

Integration tests are in `spec/integration/`. These tests make real API calls and require an API key:
```bash
ZAI_API_KEY=your-key bundle exec rspec spec/integration/
```

### VCR Cassettes

We use VCR to record and replay HTTP interactions. When adding new tests:

1. Run the test once to record the cassette
2. Review the recorded cassette for sensitive data
3. Commit the cassette with your test changes

## Documentation

### API Documentation

API documentation is generated from YARD comments. To generate locally:
```bash
bundle exec yard doc
```

To serve documentation:
```bash
bundle exec yard server
```

### Examples

Add examples to the `examples/` directory:
- Keep examples simple and focused
- Include error handling
- Use environment variables for API keys

## Release Process

1. Update version number in `lib/zai/version.rb`
2. Update `CHANGELOG.md`
3. Create a pull request for review
4. Merge after approval
5. Tag the release: `git tag v1.2.3`
6. Push tag: `git push origin v1.2.3`

## Getting Help

- Check existing issues and discussions
- Create a new issue for questions or bugs
- Join our community discussions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
```

### 2.4 Integration Guides

#### 2.4.1 Rails Integration Guide (`guides/rails-integration.md`)

```markdown
# Rails Integration Guide

This guide shows how to integrate the Z.ai Ruby SDK with Ruby on Rails applications.

## Installation

Add to your Gemfile:
```ruby
gem 'zai-ruby-sdk'
```

Then run:
```bash
bundle install
```

## Configuration

### Using Initializers

Create `config/initializers/zai.rb`:
```ruby
# config/initializers/zai.rb
Rails.application.configure do
  config.zai = ActiveSupport::OrderedOptions.new
  
  # Configure your Z.ai client
  config.zai.api_key = ENV.fetch('ZAI_API_KEY')
  config.zai.base_url = ENV.fetch('ZAI_BASE_URL', 'https://api.z.ai/api/paas/v4')
  config.zai.timeout = 30
  config.zai.max_retries = 3
end

# Create a global client
ZAI_CLIENT = Zai.client(
  api_key: Rails.application.config.zai.api_key,
  base_url: Rails.application.config.zai.base_url,
  timeout: Rails.application.config.zai.timeout,
  max_retries: Rails.application.config.zai.max_retries
)
```

### Environment Variables

Add to `.env` (use dotenv-rails in development):
```env
ZAI_API_KEY=your-api-key
ZAI_BASE_URL=https://api.z.ai/api/paas/v4
```

## Usage Patterns

### In Controllers

```ruby
class ChatController < ApplicationController
  def create
    response = ZAI_CLIENT.chat.completions(
      messages: chat_params[:message],
      model: "glm-5"
    )
    
    render json: { response: response.first_message }
  rescue Zai::APIError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
  
  private
  
  def chat_params
    params.require(:chat).permit(:message)
  end
end
```

### In Models

```ruby
class Post < ApplicationRecord
  def generate_summary
    response = ZAI_CLIENT.chat.completions(
      messages: "Summarize this post: #{content}",
      model: "glm-5",
      max_tokens: 100
    )
    
    update!(summary: response.first_message)
  end
end
```

### In Services

```ruby
class ContentGeneratorService
  def initialize(topic:)
    @topic = topic
  end
  
  def generate_blog_post
    response = ZAI_CLIENT.chat.completions(
      messages: [
        { role: "system", content: "You are a blog post writer." },
        { role: "user", content: "Write a blog post about #{@topic}" }
      ],
      model: "glm-5",
      temperature: 0.7,
      max_tokens: 1000
    )
    
    response.first_message
  end
  
  private
  
  attr_reader :topic
end
```

### In Jobs

```ruby
class GenerateContentJob < ApplicationJob
  queue_as :default
  
  def perform(post_id)
    post = Post.find(post_id)
    response = ZAI_CLIENT.chat.completions(
      messages: "Generate content for: #{post.title}",
      model: "glm-5"
    )
    
    post.update!(content: response.first_message)
  rescue Zai::APIError => e
    Rails.logger.error "Failed to generate content: #{e.message}"
    raise
  end
end
```

## Streaming in Rails

### Using Server-Sent Events (SSE)

```ruby
class StreamController < ApplicationController
  def chat
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    
    self.response_body = Enumerator.new do |stream|
      ZAI_CLIENT.chat.stream(messages: params[:message]) do |chunk|
        content = chunk.dig(:choices, 0, :delta, :content)
        stream << "data: #{content}\n\n" if content
      end
    end
  end
end
```

### Using Action Cable (WebSockets)

```ruby
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room_id]}"
  end
  
  def speak(data)
    Thread.new do
      ZAI_CLIENT.chat.stream(messages: data['message']) do |chunk|
        content = chunk.dig(:choices, 0, :delta, :content)
        ActionCable.server.broadcast(
          "chat_#{params[:room_id]}",
          { content: content }
        ) if content
      end
    end
  end
end
```

## Error Handling

### Custom Error Handling

```ruby
module ZaiErrorHandler
  def self.call(exception)
    case exception
    when Zai::AuthenticationError
      Rails.logger.error "Z.ai authentication failed: #{exception.message}"
      # Handle authentication errors
    when Zai::RateLimitError
      Rails.logger.warn "Z.ai rate limit exceeded: #{exception.message}"
      # Handle rate limiting
    when Zai::APIError
      Rails.logger.error "Z.ai API error: #{exception.message}"
      # Handle general API errors
    end
  end
end
```

### Rescuing from Errors

```ruby
class ApplicationController < ActionController::Base
  rescue_from Zai::APIError, with: :handle_zai_error
  
  private
  
  def handle_zai_error(exception)
    ZaiErrorHandler.call(exception)
    render json: { error: 'An error occurred with the AI service' }, status: :service_unavailable
  end
end
```

## Testing

### Testing Controllers

```ruby
# spec/controllers/chat_controller_spec.rb
require 'rails_helper'

RSpec.describe ChatController, type: :controller do
  let(:mock_response) { double("Response", first_message: "Hello!") }
  
  before do
    allow(ZAI_CLIENT).to receive_message_chain(:chat, :completions).and_return(mock_response)
  end
  
  describe "POST #create" do
    it "returns a chat response" do
      post :create, params: { chat: { message: "Hello" } }
      
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['response']).to eq("Hello!")
    end
  end
end
```

### Testing with VCR

```ruby
# spec/services/content_generator_service_spec.rb
require 'rails_helper'

RSpec.describe ContentGeneratorService, type: :service, vcr: true do
  describe "#generate_blog_post" do
    it "generates blog post content" do
      service = described_class.new(topic: "Ruby programming")
      content = service.generate_blog_post
      
      expect(content).to be_a(String)
      expect(content).not_to be_empty
    end
  end
end
```

## Performance Considerations

### Caching Responses

```ruby
class CachedChatService
  def initialize(topic:)
    @topic = topic
  end
  
  def generate_response
    Rails.cache.fetch("chat_response_#{Digest::MD5.hexdigest(@topic)}", expires_in: 1.hour) do
      response = ZAI_CLIENT.chat.completions(
        messages: @topic,
        model: "glm-5"
      )
      response.first_message
    end
  end
  
  private
  
  attr_reader :topic
end
```

### Background Processing

```ruby
class AiResponseJob < ApplicationJob
  queue_as :ai_requests
  
  def perform(prompt, callback_url)
    response = ZAI_CLIENT.chat.completions(messages: prompt)
    
    # Send response via webhook
    HTTP.post(callback_url, json: { response: response.first_message })
  rescue Zai::APIError => e
    # Handle error and possibly retry
  end
end
```

## Security

### Protecting API Keys

Never commit API keys to your repository. Use:
- Environment variables
- Rails encrypted credentials
- Secret management services

```ruby
# Using encrypted credentials
api_key = Rails.application.credentials.zai[:api_key]

# Using environment variables
api_key = ENV.fetch('ZAI_API_KEY')
```

### Input Validation

Always validate and sanitize user input before sending to the API:

```ruby
class ValidatedChatService
  MAX_MESSAGE_LENGTH = 4000
  
  def initialize(message:)
    @message = message
  end
  
  def generate_response
    validate_message!
    
    ZAI_CLIENT.chat.completions(messages: @message)
  end
  
  private
  
  def validate_message!
    if @message.length > MAX_MESSAGE_LENGTH
      raise ArgumentError, "Message too long"
    end
    
    # Add more validation as needed
  end
  
  attr_reader :message
end
```

## Deployment

### Heroku

```bash
heroku config:set ZAI_API_KEY=your-api-key
heroku config:set ZAI_BASE_URL=https://api.z.ai/api/paas/v4
```

### Docker

```dockerfile
FROM ruby:3.2-slim
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

ENV ZAI_API_KEY=""  # Set at runtime
ENV ZAI_BASE_URL="https://api.z.ai/api/paas/v4"

CMD ["rails", "server", "-b", "0.0.0.0"]
```
```

#### 2.4.2 Sinatra Integration Guide (`guides/sinatra-integration.md`)

```markdown
# Sinatra Integration Guide

This guide shows how to integrate the Z.ai Ruby SDK with Sinatra applications.

## Installation

Add to your Gemfile:
```ruby
gem 'sinatra'
gem 'zai-ruby-sdk'
```

## Basic Setup

### Configuration

```ruby
# app.rb
require 'sinatra'
require 'zai'

# Configure Zai client
configure do
  set :zai_client, Zai.client(
    api_key: ENV.fetch('ZAI_API_KEY'),
    base_url: ENV.fetch('ZAI_BASE_URL', 'https://api.z.ai/api/paas/v4')
  )
end

# Routes
get '/' do
  "Z.ai + Sinatra Integration"
end

post '/chat' do
  message = params[:message]
  response = settings.zai_client.chat.completions(
    messages: message,
    model: "glm-5"
  )
  
  { response: response.first_message }.to_json
end
```

### Error Handling

```ruby
error Zai::APIError do
  status 502
  content_type :json
  { error: 'AI service error', message: env['sinatra.error'].message }.to_json
end

error Zai::AuthenticationError do
  status 401
  content_type :json
  { error: 'Authentication failed' }.to_json
end
```

## Streaming with Sinatra

### Using Server-Sent Events

```ruby
get '/stream' do
  content_type 'text/event-stream'
  
  stream(:keep_open) do |out|
    settings.zai_client.chat.stream(messages: params[:message]) do |chunk|
      content = chunk.dig(:choices, 0, :delta, :content)
      out << "data: #{content}\n\n" if content
    end
  end
end
```

## Modular Sinatra

### Using Extensions

```ruby
# extensions/zai_extension.rb
module Sinatra
  module ZaiExtension
    def zai_client
      @zai_client ||= Zai.client(
        api_key: ENV.fetch('ZAI_API_KEY'),
        base_url: ENV.fetch('ZAI_BASE_URL', 'https://api.z.ai/api/paas/v4')
      )
    end
  end
  
  register ZaiExtension
end

# app.rb
require 'sinatra'
require_relative 'extensions/zai_extension'

get '/chat' do
  response = zai_client.chat.completions(
    messages: params[:message],
    model: "glm-5"
  )
  
  erb :chat_response, locals: { response: response }
end
```

## Testing

### RSpec Integration

```ruby
# spec/app_spec.rb
require 'spec_helper'
require 'sinatra'

require_relative '../app'

describe Sinatra::Application do
  let(:mock_response) { double("Response", first_message: "Hello!") }
  
  before do
    allow_any_instance_of(Sinatra::Application).to receive(:zai_client).and_return(
      double("Client", chat: double("Chat", completions: mock_response))
    )
  end
  
  describe 'POST /chat' do
    it 'returns a chat response' do
      post '/chat', { message: 'Hello' }, { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['response']).to eq('Hello!')
    end
  end
end
```

## Deployment

### Using config.ru

```ruby
# config.ru
require './app'
run Sinatra::Application
```

### Environment Variables

```bash
export ZAI_API_KEY="your-api-key"
export ZAI_BASE_URL="https://api.z.ai/api/paas/v4"
```

### Running with Passenger

```ruby
# app.rb
require 'sinatra'
require 'zai'

# Ensure Sinatra runs in production mode
set :environment, :production

# Configure client
set :zai_client, Zai.client(
  api_key: ENV.fetch('ZAI_API_KEY'),
  base_url: ENV.fetch('ZAI_BASE_URL', 'https://api.z.ai/api/paas/v4')
)
```
```

## 3. Documentation Tools

### 3.1 Recommended Tool Stack

#### Primary Tools
1. **YARD** - For API documentation generation
   - Install: `gem install yard`
   - Generate: `yardoc`
   - Serve: `yard server`
   - Deploy to rubydoc.info via GitHub integration

2. **GitHub Pages** - For static documentation hosting
   - Jekyll for site generation
   - Custom theme matching Z.ai brand
   - Multi-language support

3. **ReDoc** - For OpenAPI/Swagger documentation
   - If we generate OpenAPI specs from Ruby code

#### Secondary Tools
1. **RDoc** - For Ruby core documentation (backup)
2. **Metrictank** - For documentation metrics
3. **Grimoire** - For documentation improvement suggestions

### 3.2 YARD Configuration

#### `.yardopts` File
```
--no-private
--embed-mixins
--embed-inheritance
--markup markdown
--markup-provider redcarpet
--exclude 'spec|test|examples'
--load lib/zai.rb
```

#### `.yard/yard_template.rb` for Custom Template
```ruby
def htmlify(text)
  # Custom HTML processing
end

def format_type(type)
  # Custom type formatting
end
```

### 3.3 Documentation Generation Workflow

#### GitHub Actions Workflow

```yaml
# .github/workflows/docs.yml
name: Documentation

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main ]

jobs:
  build-docs:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.2'
        
    - name: Install dependencies
      run: |
        gem install yard redcarpet
        bundle install
        
    - name: Generate documentation
      run: |
        yardoc --output-dir docs/api
        
    - name: Generate guides
      run: |
        mkdir -p docs/guides
        cp guides/*.md docs/guides/
        
    - name: Deploy to GitHub Pages
      if: github.ref == 'refs/heads/main'
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./docs
        
    - name: Update RubyDoc.info
      if: startsWith(github.ref, 'refs/tags/')
      run: |
        # Trigger rubydoc.info update via webhook
        curl -X POST -d "token=${{ secrets.RUBYDOC_WEBHOOK_TOKEN }}" \
          https://rubydoc.info/github/z-ai-ruby/sdk/webhook
```

### 3.4 Documentation Hosting Strategy

#### Multi-Tier Approach

1. **RubyDoc.info** - Primary API documentation
   - Auto-updated on releases
   - Indexed by search engines
   - Versioned documentation

2. **GitHub Pages** - Comprehensive documentation site
   - Guides and tutorials
   - Examples and code snippets
   - Multiple language versions

3. **Platform.z.ai** - Official documentation
   - Cross-language reference
   - Platform-specific guides
   - Integration with developer portal

#### CDN and Performance

- Use GitHub's CDN for static assets
- Implement caching headers
- Optimize images and diagrams
- Minify CSS and JavaScript

## 4. Example Content

### 4.1 Example Walkthroughs

#### Quick Start Example (`examples/quick_start.rb`)

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# Quick start example for Z.ai Ruby SDK
# This example demonstrates basic chat completion functionality

require 'zai'

# Initialize the client
# You can get an API key from https://platform.z.ai
client = Zai.overseas_client(
  api_key: ENV.fetch('ZAI_API_KEY') { 
    puts "Please set ZAI_API_KEY environment variable"
    exit 1
  }
)

puts "Z.ai Ruby SDK Quick Start"
puts "=" * 30

# Example 1: Simple completion
puts "\n1. Simple Completion:"
puts "Question: What is Ruby?"
response = client.chat.completions(
  messages: "What is Ruby in 50 words or less?",
  model: "glm-5",
  max_tokens: 100
)
puts "Answer: #{response.first_message}"

# Example 2: Conversation with context
puts "\n2. Conversation with Context:"
conversation = [
  { role: "system", content: "You are a helpful Ruby expert." },
  { role: "user", content: "What's the difference between a class and a module?" },
  { role: "assistant", content: "In Ruby, classes are blueprints for objects that can be instantiated, while modules are collections of methods and constants that can be mixed into classes." },
  { role: "user", content: "Can you show me an example of each?" }
]

response = client.chat.completions(
  messages: conversation,
  model: "glm-5"
)
puts "Answer: #{response.first_message}"

# Example 3: Streamed response
puts "\n3. Streamed Response:"
puts "Question: Count from 1 to 5"
print "Answer: "

client.chat.stream(
  messages: "Count from 1 to 5, one number at a time",
  model: "glm-5"
) do |chunk|
  content = chunk.dig(:choices, 0, :delta, :content)
  print content if content
end
puts "\n"

# Example 4: Error handling
puts "\n4. Error Handling:"
begin
  # This will fail with an invalid API key
  bad_client = Zai.overseas_client(api_key: "invalid-key")
  bad_client.chat.completions(messages: "Hello")
rescue Zai::AuthenticationError => e
  puts "Authentication failed as expected: #{e.message}"
end

# Example 5: Token usage
puts "\n5. Token Usage:"
response = client.chat.completions(
  messages: "Explain Ruby's metaprogramming capabilities",
  model: "glm-5"
)

puts "Prompt tokens: #{response.usage.prompt_tokens}"
puts "Completion tokens: #{response.usage.completion_tokens}"
puts "Total tokens: #{response.usage.total_tokens}"

puts "\n" + "=" * 30
puts "Quick start complete! Check the documentation for more examples."
```

#### Real-World Example (`examples/content_generator.rb`)

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'zai'
require 'erb'
require 'fileutils'

# Content Generator Example
# Demonstrates a practical use case: generating blog post content

class BlogPostGenerator
  def initialize(api_key:)
    @client = Zai.overseas_client(api_key: api_key)
  end
  
  def generate_post(topic:, length: 'medium', tone: 'informative')
    # Step 1: Generate outline
    outline = generate_outline(topic)
    puts "Generated outline:\n#{outline}\n\n"
    
    # Step 2: Generate introduction
    introduction = generate_section(topic, "introduction", tone)
    
    # Step 3: Generate main sections
    sections = outline.split("\n").reject(&:empty?).map do |section_title|
      title = section_title.strip
      content = generate_section(topic, title, tone)
      { title: title, content: content }
    end
    
    # Step 4: Generate conclusion
    conclusion = generate_section(topic, "conclusion", tone)
    
    # Step 5: Compile into blog post
    compile_blog_post(
      topic: topic,
      introduction: introduction,
      sections: sections,
      conclusion: conclusion
    )
  end
  
  private
  
  def generate_outline(topic)
    response = @client.chat.completions(
      messages: [
        { 
          role: "system", 
          content: "You are a content strategist. Create a structured outline for a blog post. Use a numbered list format." 
        },
        { 
          role: "user", 
          content: "Create an outline for a blog post about '#{topic}'. Include introduction, 3-4 main sections, and conclusion." 
        }
      ],
      model: "glm-5",
      temperature: 0.3
    )
    
    response.first_message
  end
  
  def generate_section(topic, section_type, tone)
    prompts = {
      "introduction" => "Write an engaging introduction for a blog post about '#{topic}'. The tone should be #{tone}.",
      "conclusion" => "Write a compelling conclusion for a blog post about '#{topic}'. Summarize key points and provide a call to action."
    }
    
    prompt = prompts[section_type] || "Write a detailed section about '#{section_type}' in a blog post about '#{topic}'. The tone should be #{tone}."
    
    response = @client.chat.completions(
      messages: [
        { 
          role: "system", 
          content: "You are an expert blogger and writer. Write engaging, well-structured content." 
        },
        { role: "user", content: prompt }
      ],
      model: "glm-5",
      temperature: 0.7,
      max_tokens: 300
    )
    
    response.first_message
  end
  
  def compile_blog_post(topic:, introduction:, sections:, conclusion:)
    template = ERB.new(<<~MARKDOWN)
      # <%= topic %>
      
      ## Introduction
      <%= introduction %>
      
      <% sections.each do |section| %>
      ## <%= section[:title] %>
      <%= section[:content] %>
      
      <% end %>
      ## Conclusion
      <%= conclusion %>
      
      ---
      *This blog post was generated using Z.ai's Ruby SDK*
    MARKDOWN
    
    template.result_with_hash(
      topic: topic,
      introduction: introduction,
      sections: sections,
      conclusion: conclusion
    )
  end
  
  attr_reader :client
end

# Usage example
if __FILE__ == $0
  api_key = ENV.fetch('ZAI_API_KEY') do
    puts "Please set ZAI_API_KEY environment variable"
    exit 1
  end
  
  generator = BlogPostGenerator.new(api_key: api_key)
  
  # Generate a blog post
  topic = ARGV[0] || "The Future of AI in Software Development"
  post_content = generator.generate_post(topic: topic, length: 'medium', tone: 'informative')
  
  # Save to file
  filename = "blog_post_#{topic.downcase.gsub(/\s+/, '_')}.md"
  File.write(filename, post_content)
  
  puts "\nBlog post saved to: #{filename}"
end
```

### 4.2 Tutorial Content

#### Beginner Tutorial (`guides/tutorials/beginner.md`)

```markdown
# Beginner Tutorial: Building Your First AI-Powered Ruby Application

Welcome to the Z.ai Ruby SDK beginner tutorial! In this guide, you'll build a simple command-line application that uses AI to generate text.

## What We'll Build

We'll create a Ruby script that:
1. Accepts user input from the command line
2. Sends the input to Z.ai's chat model
3. Displays the AI's response
4. Handles common errors gracefully

## Prerequisites

Before starting, make sure you have:
- Ruby 2.7 or newer installed
- A Z.ai API key (get one at https://platform.z.ai)
- Basic familiarity with Ruby

## Step 1: Project Setup

First, create a new directory for your project:

```bash
mkdir my_ai_app
cd my_ai_app
```

Create a Gemfile to manage dependencies:

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'zai-ruby-sdk'
```

Install the dependencies:

```bash
bundle install
```

## Step 2: Basic Implementation

Create a file called `app.rb`:

```ruby
#!/usr/bin/env ruby
require 'zai'
require 'dotenv/load'

# Set up the client with your API key
api_key = ENV.fetch('ZAI_API_KEY') do
  puts "Please set ZAI_API_KEY in your environment or .env file"
  exit 1
end

client = Zai.overseas_client(api_key: api_key)

# Get user input
puts "What would you like to ask the AI?"
user_input = gets.chomp

# Send to AI and get response
puts "\nThinking..."
response = client.chat.completions(
  messages: user_input,
  model: "glm-5"
)

puts "\nAI Response:"
puts response.first_message
```

## Step 3: Running Your Application

First, create a `.env` file with your API key:

```env
ZAI_API_KEY=your-api-key-goes-here
```

Now run your application:

```bash
ruby app.rb
```

Try asking questions like:
- "What is Ruby programming?"
- "Explain object-oriented programming"
- "Tell me a joke"

## Step 4: Adding Error Handling

Let's make our application more robust by handling potential errors:

```ruby
#!/usr/bin/env ruby
require 'zai'
require 'dotenv/load'

class AIAssistant
  def initialize
    @client = Zai.overseas_client(
      api_key: ENV.fetch('ZAI_API_KEY') do
        puts "Please set ZAI_API_KEY in your environment or .env file"
        exit 1
      end
    )
  end
  
  def ask(question)
    puts "\nThinking..."
    
    response = @client.chat.completions(
      messages: question,
      model: "glm-5"
    )
    
    response.first_message
  rescue Zai::AuthenticationError => e
    puts "Authentication failed: Please check your API key"
    puts "Error details: #{e.message}"
  rescue Zai::RateLimitError => e
    puts "Rate limit exceeded. Please try again later."
  rescue Zai::APIError => e
    puts "An error occurred: #{e.message}"
  end
  
  private
  
  attr_reader :client
end

# Main application loop
assistant = AIAssistant.new

puts "AI Assistant (type 'quit' to exit)"
puts "=" * 40

loop do
  print "\nYou: "
  user_input = gets.chomp
  
  break if user_input.downcase == 'quit'
  next if user_input.empty?
  
  puts "AI: #{assistant.ask(user_input)}"
end

puts "\nGoodbye!"
```

## Step 5: Adding Conversation Memory

Our application currently has no memory of previous messages. Let's fix that:

```ruby
class AIAssistant
  def initialize
    @client = Zai.overseas_client(
      api_key: ENV.fetch('ZAI_API_KEY') do
        puts "Please set ZAI_API_KEY in your environment or .env file"
        exit 1
      end
    )
    @conversation = []
  end
  
  def ask(question)
    # Add user message to conversation
    @conversation << { role: "user", content: question }
    
    # Keep conversation to last 10 messages to manage token usage
    @conversation = @conversation.last(10) if @conversation.size > 10
    
    puts "\nThinking..."
    
    response = @client.chat.completions(
      messages: @conversation,
      model: "glm-5"
    )
    
    answer = response.first_message
    
    # Add AI response to conversation
    @conversation << { role: "assistant", content: answer }
    
    answer
  rescue Zai::AuthenticationError => e
    puts "Authentication failed: Please check your API key"
    puts "Error details: #{e.message}"
  rescue Zai::RateLimitError => e
    puts "Rate limit exceeded. Please try again later."
  rescue Zai::APIError => e
    puts "An error occurred: #{e.message}"
  end
  
  private
  
  attr_reader :client, :conversation
end
```

## Step 6: Adding Features

Let's add a few more features to make our application more interesting:

```ruby
class AIAssistant
  def initialize
    @client = Zai.overseas_client(
      api_key: ENV.fetch('ZAI_API_KEY') do
        puts "Please set ZAI_API_KEY in your environment or .env file"
        exit 1
      end
    )
    @conversation = []
    @mode = :general  # Can be :general, :creative, :precise
  end
  
  def ask(question)
    # Check for commands
    return handle_command(question) if question.start_with?('/')
    
    # Add user message to conversation
    @conversation << { role: "user", content: question }
    
    # Manage conversation size
    @conversation = @conversation.last(10) if @conversation.size > 10
    
    puts "\nThinking..."
    
    response = @client.chat.completions(
      messages: build_prompt,
      model: "glm-5",
      temperature: temperature_for_mode(@mode)
    )
    
    answer = response.first_message
    @conversation << { role: "assistant", content: answer }
    
    answer
  rescue Zai::APIError => e
    puts "Error: #{e.message}"
  end
  
  def set_mode(new_mode)
    modes = [:general, :creative, :precise]
    if modes.include?(new_mode.to_sym)
      @mode = new_mode.to_sym
      puts "Mode set to #{@mode}"
    else
      puts "Available modes: #{modes.join(', ')}"
    end
  end
  
  private
  
  def handle_command(command)
    case command
    when '/help'
      show_help
    when '/clear'
      @conversation.clear
      puts "Conversation cleared."
    when '/mode'
      puts "Current mode: #{@mode}"
    when /^\/mode (\w+)$/
      set_mode($1)
    when '/quit'
      puts "Goodbye!"
      exit 0
    else
      puts "Unknown command. Type /help for available commands."
    end
  end
  
  def show_help
    puts <<~HELP
      Available commands:
      /help    - Show this help message
      /clear   - Clear conversation history
      /mode    - Show current mode
      /mode <mode> - Set mode (general, creative, precise)
      /quit    - Exit the application
      
      Modes:
      general  - Balanced responses (temperature: 0.7)
      creative - More creative responses (temperature: 0.9)
      precise  - More focused responses (temperature: 0.3)
    HELP
  end
  
  def build_prompt
    system_message = case @mode
                    when :creative
                      "You are a creative AI assistant. Be imaginative and explore ideas freely."
                    when :precise
                      "You are a precise AI assistant. Provide accurate, focused answers."
                    else
                      "You are a helpful AI assistant."
                    end
    
    [{ role: "system", content: system_message }] + @conversation
  end
  
  def temperature_for_mode(mode)
    case mode
    when :creative then 0.9
    when :precise then 0.3
    else 0.7
    end
  end
  
  attr_reader :client, :conversation, :mode
end

# Main application
assistant = AIAssistant.new

puts "AI Assistant v1.0"
puts "Type /help for commands"
puts "=" * 40

loop do
  print "\nYou: "
  user_input = gets.chomp
  
  response = assistant.ask(user_input)
  puts "AI: #{response}" if response
end
```

## What We've Learned

In this tutorial, you've learned how to:
1. Set up a Ruby project with the Z.ai SDK
2. Initialize and configure the client
3. Make API calls to generate text
4. Handle errors gracefully
5. Maintain conversation context
6. Add interactive features

## Next Steps

- Explore the [Chat Completions Guide](../chat-completions.md) for more advanced options
- Check out the [Examples directory](../../examples/) for more use cases
- Learn about [streaming responses](../streaming.md) for real-time applications
- Read the [API Reference](https://rubydoc.info/gems/zai-ruby-sdk) for complete documentation

## Complete Code

The complete code for this tutorial is available in the [examples directory](../../examples/beginner_tutorial.rb).
```

## 5. Documentation Maintenance

### 5.1 Documentation Updates with Releases

#### Release Documentation Checklist

```markdown
## Release Documentation Checklist

### Pre-Release (1 week before)
- [ ] Review all API documentation for accuracy
- [ ] Update version numbers in all documentation files
- [ ] Write release notes for CHANGELOG.md
- [ ] Verify all examples still work
- [ ] Check for broken links in documentation

### Release Day
- [ ] Update CHANGELOG.md with release notes
- [ ] Update version in `lib/zai/version.rb`
- [ ] Generate and deploy API documentation
- [ ] Create GitHub release with documentation
- [ ] Update project README if needed
- [ ] Update RubyGems description

### Post-Release (within 1 week)
- [ ] Monitor documentation for reported issues
- [ ] Review analytics on documentation usage
- [ ] Plan documentation improvements for next release
- [ ] Update any outdated guides
- [ ] Thank contributors in release notes
```

### 5.2 Documentation Review Process

#### Documentation Pull Request Template

```markdown
## Documentation Changes

### Type of Change
- [ ] API documentation update
- [ ] Guide/tutorial update
- [ ] Example code update
- [ ] README update
- [ ] Other: ___________

### Description
Briefly describe what documentation changes were made and why.

### Areas Updated
- [ ] API Reference
- [ ] Getting Started Guide
- [ ] Examples
- [ ] Integration Guides
- [ ] Migration Guides
- [ ] Troubleshooting

### Testing
- [ ] Verified all code examples work
- [ ] Tested all linked resources
- [ ] Reviewed for clarity and accuracy
- [ ] Checked for consistent formatting

### Review Checklist
- [ ] Documentation follows style guide
- [ ] All links are valid
- [ ] Code examples are formatted correctly
- [ ] No typos or grammatical errors
- [ ] Version information is accurate
```

### 5.3 Multilingual Support Strategy

#### Phase 1: English (Primary)
- Complete documentation in English
- Internationalization-ready structure
- Clear, simple language to ease translation

#### Phase 2: Major Languages (Months 4-6)
- Chinese (Simplified)
- Japanese
- Spanish

#### Phase 3: Additional Languages (Months 7-12)
- French
- German
- Korean
- Portuguese (Brazil)

#### Translation Process

1. **Preparation**
   - Extract all translatable content
   - Create translation glossary
   - Establish style guides per language

2. **Translation**
   - Use professional translators familiar with Ruby
   - Technical review by native Ruby developers
   - Community review and feedback

3. **Maintenance**
   - Track changes in source documentation
   - Incremental translation updates
   - Community contribution system

## 6. Integration with Git Workflow

### 6.1 Documentation in Release Process

#### Branch Strategy for Documentation

```
main                    # Production documentation
├── develop            # Staging documentation
├── docs/feature-name  # Feature documentation
├── docs/fix-typo      # Quick documentation fixes
└── release/v1.2.0     # Release documentation updates
```

#### Documentation Commit Convention

```
docs: update API reference for new endpoints
docs: add Rails integration guide
docs: fix broken link in getting started
docs: translate README to Chinese
docs: refactor examples directory structure
```

### 6.2 Automated Documentation Checks

#### GitHub Actions Workflow

```yaml
# .github/workflows/docs-checks.yml
name: Documentation Checks

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'docs/**'
      - 'guides/**'
      - 'examples/**'
      - '**.md'
  pull_request:
    branches: [ main, develop ]
    paths:
      - 'docs/**'
      - 'guides/**'
      - 'examples/**'
      - '**.md'

jobs:
  verify-links:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Check links
      uses: lycheeverse/lychee-action@v1.8.0
      with:
        args: --verbose --no-progress '**/*.md'
        fail: true
        
  spell-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Spell check
      uses: streetsidesoftware/cspell-action@v2
      with:
        files: '**/*.md'
        config: '.cspell.json'
        
  validate-examples:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.2'
        
    - name: Install dependencies
      run: |
        gem install zai-ruby-sdk
        bundle install
        
    - name: Validate Ruby examples
      env:
        ZAI_API_KEY: ${{ secrets.TEST_API_KEY }}
      run: |
        for example in examples/**/*.rb; do
          echo "Validating $example"
          ruby -c "$example" || exit 1
        done
        
  yard-docs:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.2'
        
    - name: Install dependencies
      run: |
        gem install yard
        bundle install
        
    - name: Generate YARD docs
      run: |
        yardoc --no-private --list-undoc
        
    - name: Check for undocumented public methods
      run: |
        if yard stats --list-undoc | grep -q "@undoc"; then
          echo "Error: Found undocumented public methods"
          exit 1
        fi
```

### 6.3 Documentation Testing

#### RSpec Tests for Documentation

```ruby
# spec/documentation_examples_spec.rb
require 'spec_helper'
require 'tempfile'

RSpec.describe "Documentation Examples" do
  let(:test_api_key) { "test-key" }
  
  # Test code snippets from README
  describe "README examples" do
    it "quick start example works" do
      code = File.read('README.md')[/```ruby\n(.*?)\n```m, 1]
      
      # Create a temporary file with the example
      Tempfile.open(['example', '.rb']) do |file|
        file.write("require 'zai'\n")
        file.write(code.gsub('Zai.overseas_client(api_key: "your-api-key")', 
                            "Zai.overseas_client(api_key: '#{test_api_key}')"))
        file.flush
        
        # Verify syntax
        expect(system("ruby -c #{file.path}")).to be_truthy
      end
    end
  end
  
  # Test example files
  describe "Example files" do
    Dir.glob('examples/**/*.rb').each do |example_file|
      it "#{example_file} has valid syntax" do
        expect(system("ruby -c #{example_file}")).to be_truthy
      end
      
      it "#{example_file} runs without errors" do
        # This would require mocking API responses
        # For now, just check that it loads without syntax errors
        load example_file
      end
    end
  end
  
  # Test guide code snippets
  describe "Guide examples" do
    Dir.glob('guides/**/*.md').each do |guide_file|
      describe File.basename(guide_file) do
        let(:content) { File.read(guide_file) }
        
        it "has valid Ruby code blocks" do
          code_blocks = content.scan(/```ruby\n(.*?)\n```m)
          
          code_blocks.each do |code|
            Tempfile.open(['guide_example', '.rb']) do |file|
              file.write(code[0])
              file.flush
              
              expect(system("ruby -c #{file.path}")).to be_truthy
            end
          end
        end
      end
    end
  end
end
```

## 7. Ruby Version-Specific Documentation

### 7.1 Ruby 3.2+ Performance Benefits

#### 7.1.1 YJIT Compiler

Ruby 3.2+ includes the YJIT (Yet Another Just-In-Time) compiler which provides significant performance improvements:

```ruby
# Enable YJIT optimizations in your application
# This is automatically done by the SDK on Ruby 3.2+
if defined?(RubyVM::YJIT)
  RubyVM::YJIT.enable
end

# Performance benchmark example
require 'benchmark'
require 'zai'

client = Zai.overseas_client(api_key: ENV["ZAI_API_KEY"])

# Compare performance with and without YJIT
Benchmark.bm(20) do |x|
  x.report("With YJIT:") do
    100.times { client.chat.completions(messages: "Hello") }
  end
  
  x.report("Without YJIT:") do
    RubyVM::YJIT.disable if defined?(RubyVM::YJIT)
    100.times { client.chat.completions(messages: "Hello") }
  end
end
```

#### 7.1.2 Memory Optimization

Ruby 3.2+ includes memory management improvements:

```ruby
# The SDK automatically configures GC for Ruby 3.2+
# You can further optimize memory usage:

# Enable compaction (Ruby 3.2+)
GC.compact

# Configure GC tuning for the SDK
GC.opts[:minor_gc_tuning] = {
  :full_mark_threshold => 1.0,
  :step_size => 1.1
}
```

#### 7.1.3 Data Classes

Ruby 3.2+ introduces data classes for immutable structs:

```ruby
# The SDK uses data classes when available on Ruby 3.2+
# This provides better performance for model creation:

# Before (Ruby < 3.2)
class OldMessage
  attr_reader :role, :content
  def initialize(role:, content:)
    @role = role
    @content = content
  end
end

# After (Ruby 3.2+)
data class NewMessage
  attr_reader :role, :content
  
  def initialize(role:, content:)
    @role = role
    @content = content
  end
end

# Performance comparison
Benchmark.bm(20) do |x|
  x.report("Old message class:") do
    10000.times { OldMessage.new(role: "user", content: "test") }
  end
  
  x.report("Data class (Ruby 3.2+):") do
    10000.times { NewMessage.new(role: "user", content: "test") }
  end
end
```

### 7.2 JRuby-Specific Features

#### 7.2.1 Concurrent Processing

JRuby 10.0.4.0+ enables true parallel processing:

```ruby
# The SDK provides JRuby-specific concurrent client
require 'zai/jruby'

client = Zai::JRuby::ConcurrentClient.new(api_key: ENV["ZAI_API_KEY"])

# Process multiple requests in parallel
requests = [
  { messages: "What is Ruby?" },
  { messages: "What is JRuby?" },
  { messages: "What is YJIT?" }
]

# Parallel processing
responses = client.parallel_completions(requests)

# This utilizes multiple CPU cores available on JRuby
```

#### 7.2.2 Java Integration

JRuby can leverage Java libraries for enhanced performance:

```ruby
# Use Java HTTP client for better performance
if defined?(JRUBY_VERSION)
  client = Zai::JRuby::JavaIntegration.create_http_client("https://api.z.ai")
  
  # This uses Java's HTTP/2 client with native optimizations
  response = client.post("/chat/completions", {
    model: "glm-5",
    messages: [{ role: "user", content: "Hello" }]
  })
end
```

## 8. Deliverables

### 8.1 Documentation Structure Plan

```
docs/
├── api/                          # Generated YARD documentation
│   ├── index.html
│   └── frames.html
├── guides/                       # User guides and tutorials
│   ├── getting-started.md
│   ├── chat-completions.md
│   ├── streaming.md
│   ├── embeddings.md
│   ├── images.md
│   ├── error-handling.md
│   ├── authentication.md
│   ├── migration.md
│   └── troubleshooting.md
├── integration/                  # Integration guides
│   ├── rails.md
│   ├── sinatra.md
│   └── background-jobs.md
├── tutorials/                    # Step-by-step tutorials
│   ├── beginner.md
│   ├── intermediate.md
│   └── advanced.md
├── examples/                     # Code examples
│   ├── quick_start.rb
│   ├── chat_bot.rb
│   ├── content_generator.rb
│   └── rails_integration/
├── assets/                       # Static assets
│   ├── css/
│   ├── js/
│   └── images/
├── translations/                 # Multi-language support
│   ├── zh-CN/
│   ├── ja/
│   └── es/
├── README.md                     # Main documentation index
├── CHANGELOG.md                  # Version history
├── CONTRIBUTING.md               # Contributing guidelines
└── _config.yml                   # Jekyll configuration
```

### 7.2 Sample Documentation Content

#### Getting Started Guide (Chinese Translation)

```markdown
# 入门指南

本指南将帮助您快速开始使用 Z.ai Ruby SDK。

## 前提条件

- Ruby 2.7+（推荐 Ruby 3.0+）
- Z.ai API 密钥（在 https://platform.z.ai 获取）

## 安装

### 选项 1：使用 Bundler（推荐）

在 Gemfile 中添加：
```ruby
gem 'zai-ruby-sdk'
```

然后运行：
```bash
bundle install
```

### 选项 2：直接安装

```bash
gem install zai-ruby-sdk
```

## 您的第一个 API 调用

### 1. 设置您的 API 密钥

```ruby
# 选项 A：直接初始化
client = Zai.overseas_client(api_key: "your-api-key-here")

# 选项 B：环境变量
# 在 shell 中设置：
# export ZAI_API_KEY="your-api-key-here"
client = Zai.overseas_client
```

### 2. 发起您的第一个请求

```ruby
require 'zai'

client = Zai.overseas_client(api_key: ENV["ZAI_API_KEY"])

response = client.chat.completions(
  messages: "您好，Z.ai！请告诉我一些关于 Ruby 的趣事。",
  model: "glm-5"
)

puts response.first_message
```

### 3. 运行！

将代码保存到 `hello_zai.rb` 并运行：
```bash
ruby hello_zai.rb
```

## 了解响应

`response` 对象包含：

```ruby
response.id           # 完成的唯一标识符
response.object       # 对象类型（通常是 "chat.completion"）
response.created       # 创建的 Unix 时间戳
response.model        # 使用的模型
response.choices       # 完成选择的数组
response.usage        # 令牌使用信息

# 获取主要响应文本
response.first_message
```

## 下一步

- 探索[聊天完成](./chat-completions.md)
- 了解[流式响应](./streaming.md)
- 查看[示例](../examples/)
- 阅读[API 参考](https://rubydoc.info/gems/zai-ruby-sdk)
```

### 7.3 Documentation Tooling Recommendations

#### Gemfile for Documentation

```ruby
# Gemfile
source 'https://rubygems.org'

# Main dependencies
gem 'zai-ruby-sdk'

# Documentation dependencies
group :docs do
  gem 'yard', '~> 0.9'
  gem 'redcarpet', '~> 3.5'
  gem 'jekyll', '~> 4.3'
  gem 'jekyll-sitemap'
  gem 'jekyll-seo-tag'
  gem 'jekyll-feed'
  gem 'jekyll-redirect-from'
  
  # Documentation verification
  gem 'lychee', '~> 0.14'  # Link checker
  gem 'cspell'              # Spell checker
  
  # Internationalization
  gem 'i18n'
  gem 'jekyll-multiple-languages-plugin'
end

# Development dependencies
group :development do
  gem 'guard'
  gem 'guard-yard'
  gem 'guard-livereload'
end
```

#### Rakefile for Documentation Tasks

```ruby
# Rakefile
require 'yard'

namespace :docs do
  desc "Generate YARD documentation"
  task :generate do
    YARD::CLI.run(['--output-dir', 'docs/api'])
  end
  
  desc "Serve documentation locally"
  task :serve do
    require 'webrick'
    
    port = ENV['PORT'] || 8808
    
    # Start YARD server in background
    yard_thread = Thread.new do
      YARD::CLI.run(['--server', '--port', port.to_s])
    end
    
    # Start Jekyll for guides
    jekyll_thread = Thread.new do
      system("bundle exec jekyll serve --port #{port + 1} --watch")
    end
    
    puts "Documentation serving on:"
    puts "  API: http://localhost:#{port}"
    puts "  Guides: http://localhost:#{port + 1}"
    
    yard_thread.join
    jekyll_thread.join
  end
  
  desc "Check documentation links"
  task :check_links do
    puts "Checking links..."
    system("lychee '**/*.md' --verbose --no-progress")
  end
  
  desc "Check spelling"
  task :spell do
    puts "Checking spelling..."
    system("cspell '**/*.md' --config .cspell.json")
  end
  
  desc "Validate all examples"
  task :validate_examples do
    require 'spec_helper'
    
    puts "Validating Ruby syntax for all examples..."
    Dir.glob('examples/**/*.rb').each do |file|
      puts "  Checking #{file}"
      unless system("ruby -c #{file}")
        puts "    ERROR: Invalid syntax in #{file}"
        exit 1
      end
    end
    
    puts "All examples have valid syntax!"
  end
  
  desc "Run all documentation checks"
  task :check => [:check_links, :spell, :validate_examples]
  
  desc "Build complete documentation site"
  task :build => :generate do
    # Copy guides to docs directory
    system("cp -r guides docs/")
    system("cp -r examples docs/")
    system("cp README.md docs/index.md")
    system("cp CHANGELOG.md docs/changelog.md")
    
    puts "Documentation built successfully!"
  end
end

# Default documentation task
desc "Generate and serve documentation"
task :docs => ['docs:serve']

# Add documentation checks to CI task
if Rake::Task.task_defined?(:ci)
  Rake::Task[:ci].enhance ['docs:check']
end
```

### 7.4 Maintenance and Update Strategy

#### Documentation Maintenance Schedule

```yaml
# documentation_maintenance.yaml
monthly_tasks:
  - task: "Review all API documentation for accuracy"
    owner: "technical_writer"
    due: "1st of each month"
    
  - task: "Update examples with latest best practices"
    owner: "developer_advocate"
    due: "15th of each month"
    
  - task: "Check for broken links across all documentation"
    owner: "documentation_team"
    due: "3rd of each month"
    
  - task: "Review and update getting started guide"
    owner: "technical_writer"
    due: "Last Friday of each month"

quarterly_tasks:
  - task: "Comprehensive documentation review"
    owner: "documentation_team"
    due: "End of quarter"
    
  - task: "Analyze documentation usage metrics and plan improvements"
    owner: "product_manager"
    due: "Quarterly planning"
    
  - task: "Update integration guides for framework versions"
    owner: "developer_advocate"
    due: "After major framework releases"

release_tasks:
  - task: "Update version numbers in all documentation"
    owner: "release_manager"
    trigger: "pre-release"
    
  - task: "Write release notes for CHANGELOG.md"
    owner: "technical_writer"
    trigger: "pre-release"
    
  - task: "Generate and deploy API documentation"
    owner: "documentation_team"
    trigger: "release day"
    
  - task: "Update README with new features"
    owner: "technical_writer"
    trigger: "release day"
    
  - task: "Create GitHub release with documentation"
    owner: "release_manager"
    trigger: "release day"
```

## Conclusion

This comprehensive documentation plan provides a structured approach to creating, maintaining, and evolving the documentation for the Z.ai Ruby SDK. The plan emphasizes:

1. **User-Centric Approach**: Documentation organized by user needs and skill levels
2. **Practical Examples**: Real-world code examples that developers can adapt
3. **Ruby Community Standards**: Following Ruby documentation conventions and best practices
4. **Maintenance Strategy**: Clear processes for keeping documentation current
5. **Internationalization**: Planning for multi-language support
6. **Automation**: Leveraging tools to ensure documentation quality and accuracy

The documentation team can implement this plan directly, using the provided templates, examples, and workflows to create a comprehensive, professional documentation site that serves Ruby developers effectively.