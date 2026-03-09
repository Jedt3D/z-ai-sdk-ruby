# Z.ai Ruby SDK Documentation

Welcome to the Z.ai Ruby SDK documentation. This guide covers everything you need to integrate Z.ai's AI services into your Ruby applications.

## Table of Contents

### Getting Started

- **[API Overview](API.md)** - Complete API reference and usage guide
- **[Configuration Guide](CONFIGURATION.md)** - Configure the SDK for your needs

### API References

- **[Chat Completions API](CHAT_API.md)** - Text generation and conversation
- **[Embeddings API](EMBEDDINGS_API.md)** - Text vector embeddings
- **[Images API](IMAGES_API.md)** - Image generation from text
- **[Files API](FILES_API.md)** - File management for fine-tuning

### Advanced Topics

- **[Error Handling](ERROR_HANDLING.md)** - Comprehensive error handling guide
- **[Streaming](STREAMING.md)** - Real-time response streaming
- **[Rails Integration](RAILS_INTEGRATION.md)** - Using with Ruby on Rails
- **[Async Programming](ASYNC_PROGRAMMING.md)** - Concurrent and parallel operations

### Examples

Check the `/examples` directory for working code samples:

- `basic_chat.rb` - Basic chat completion examples
- `advanced_usage.rb` - Advanced features and patterns
- `embeddings.rb` - Embedding generation and similarity
- `images.rb` - Image generation examples
- `files.rb` - File upload and management
- `error_handling_examples.rb` - Error handling patterns
- `async_programming_examples.rb` - Concurrent programming
- `streaming_chat_examples.rb` - Streaming responses
- `batch_processing_examples.rb` - Batch operations
- `configuration_examples.rb` - Configuration options

Each example includes a detailed walkthrough document.

## Installation

```ruby
# In Gemfile
gem 'zai-ruby-sdk'

# Or install directly
gem install zai-ruby-sdk
```

## Quick Start

```ruby
require 'z/ai'

# Configure
Z::AI.configure do |config|
  config.api_key = ENV['ZAI_API_KEY']
end

# Create chat completion
response = Z::AI.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'Hello, Z.ai!' }
  ]
)

puts response.content
```

## Features

- ✅ **Chat Completions** - Text generation with streaming support
- ✅ **Embeddings** - Vector embeddings for semantic search
- ✅ **Images** - Image generation from text prompts
- ✅ **Files** - File management for fine-tuning
- ✅ **Authentication** - JWT token caching
- ✅ **Error Handling** - Comprehensive error hierarchy
- ✅ **Retry Logic** - Automatic retries with exponential backoff
- ✅ **Rails Integration** - Seamless Rails support
- ✅ **Async Support** - Concurrent operations

## Ruby Compatibility

- Ruby 3.2.8+
- JRuby 10.0.4.0+

## Configuration

### Environment Variables

```bash
export ZAI_API_KEY="your-api-key"
export ZAI_BASE_URL="https://api.z.ai/api/paas/v4/"
export ZAI_LOG_LEVEL="info"
```

### Code Configuration

```ruby
Z::AI.configure do |config|
  config.api_key = 'your-api-key'
  config.base_url = 'https://api.z.ai/api/paas/v4/'
  config.timeout = 60
  config.max_retries = 5
  config.logger = Logger.new(STDOUT)
  config.log_level = :debug
end
```

## Resources

- **GitHub**: https://github.com/Jedt3D/z-ai-sdk-ruby
- **API Docs**: https://docs.z.ai/api
- **Issues**: https://github.com/Jedt3D/z-ai-sdk-ruby/issues
- **Email**: sjedt@3ddaily.com

## License

MIT License - see [LICENSE](../LICENSE) for details.

## Version

Current version: **0.1.0**

---

**Need help?** Check our [examples](../examples/) or open an [issue](https://github.com/Jedt3D/z-ai-sdk-ruby/issues).
