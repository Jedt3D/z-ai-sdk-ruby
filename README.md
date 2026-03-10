# Z.ai Ruby SDK

A Ruby SDK for interacting with Z.ai AI services, providing idiomatic Ruby bindings for chat completions, embeddings, and other AI features.

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

## Requirements

- Ruby >= 3.4.8
- JRuby >= 10.0.4.0 (Ruby 3.4 compatible)

## Quick Start

### Configuration

```ruby
require 'z/ai'

# Configure globally
Z::AI.configure do |config|
  config.api_key = ENV['ZAI_API_KEY']
  config.timeout = 30
end

# Or create a client instance
client = Z::AI::Client.new(
  api_key: 'your-api-key-here',
  timeout: 30,
  max_retries: 3
)
```

### Basic Chat Completion

```ruby
# Using global client
response = Z::AI.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' },
    { role: 'user', content: 'Hello, Z.ai!' }
  ]
)

puts response.choices.first.message.content

# Using client instance
client = Z::AI::Client.new(api_key: 'your-api-key')
response = client.chat.completions.create(
  model: 'glm-5',
  messages: [{ role: 'user', content: 'Tell me a joke' }]
)

puts response.content
```

### Streaming Response

```ruby
client.chat.completions.create(
  model: 'glm-5',
  messages: [{ role: 'user', content: 'Write a short story' }],
  stream: true
) do |chunk|
  print chunk.delta_content if chunk.delta_content
end
```

Or using an enumerator:

```ruby
stream = client.chat.completions.create(
  model: 'glm-5',
  messages: [{ role: 'user', content: 'Count to 10' }],
  stream: true
)

stream.each do |chunk|
  puts chunk.delta_content
end
```

### Advanced Options

```ruby
response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'Generate creative text' }
  ],
  temperature: 0.9,        # Creativity (0.0 - 2.0)
  max_tokens: 100,         # Max response length
  top_p: 0.95,            # Nucleus sampling
  presence_penalty: 0.6,   # Encourage new topics
  frequency_penalty: 0.3   # Reduce repetition
)
```

## What Can You Build?

With the Z.ai Ruby SDK you can build:

- **Chatbots & assistants** — conversational AI with multi-turn memory and streaming responses
- **Content generation tools** — articles, summaries, code reviews, and creative writing
- **Semantic search systems** — find documents by meaning, not just keywords
- **Image generation apps** — generate images from text prompts and save them locally
- **Data processing pipelines** — analyze, classify, and extract information from documents
- **Rails AI features** — add AI to any web app with initializers, controllers, and background jobs

See the [tutorials/](tutorials/) folder for step-by-step project guides, and [examples/](examples/) for runnable code samples.

## Features

### Authentication

The SDK supports two authentication modes:

1. **API Key (Direct)**: Use your API key directly
2. **JWT Token (Cached)**: Automatically generate and cache JWT tokens

```ruby
# Direct API key (simpler)
client = Z::AI::Client.new(
  api_key: 'your-api-key',
  disable_token_cache: true
)

# JWT token with caching (default, more efficient)
client = Z::AI::Client.new(
  api_key: 'your-api-key.id.secret'
)
```

### Error Handling

```ruby
begin
  response = client.chat.completions.create(
    model: 'glm-5',
    messages: []
  )
rescue Z::AI::ValidationError => e
  puts "Invalid input: #{e.message}"
rescue Z::AI::APIAuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue Z::AI::APIRateLimitError => e
  puts "Rate limit exceeded. Status: #{e.http_status}"
rescue Z::AI::APIStatusError => e
  puts "API error: #{e.message} (#{e.http_status})"
end
```

### Retry Logic

The SDK automatically retries failed requests:

```ruby
client = Z::AI::Client.new(
  api_key: 'your-api-key',
  max_retries: 3,
  retry_delay: 1  # seconds
)
```

### Logging

```ruby
require 'logger'

Z::AI.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.log_level = :debug
end
```

### Proxy Support

```ruby
client = Z::AI::Client.new(
  api_key: 'your-api-key',
  proxy_url: 'http://proxy.example.com:8080'
)
```

## API Reference

### Chat Completions

```ruby
# Create completion
response = client.chat.completions.create(
  model: 'glm-5',           # Required: Model name
  messages: [...],          # Required: Array of messages
  stream: false,            # Optional: Enable streaming
  temperature: 0.7,         # Optional: Temperature
  max_tokens: 100,          # Optional: Max tokens
  top_p: 0.9,              # Optional: Top-p sampling
  **other_options          # Additional parameters
)
```

### Response Object

```ruby
response.id              # Unique response ID
response.object          # Object type
response.created         # Creation timestamp
response.model           # Model used
response.choices         # Array of choices
response.choices[0].message.content    # Response text
response.choices[0].finish_reason      # Completion reason
response.usage.prompt_tokens           # Tokens in prompt
response.usage.completion_tokens       # Tokens in completion
response.usage.total_tokens            # Total tokens
```

### Message Types

```ruby
# Simple text message
{ role: 'user', content: 'Hello' }

# System message
{ role: 'system', content: 'You are a helpful assistant' }

# Assistant message
{ role: 'assistant', content: 'Hi! How can I help?' }

# Multimodal message (vision)
{
  role: 'user',
  content: [
    { type: 'text', text: 'What is in this image?' },
    {
      type: 'image_url',
      image_url: { url: 'data:image/jpeg;base64,...' }
    }
  ]
}
```

### Embeddings API

Create vector embeddings for text:

```ruby
# Single text embedding
response = client.embeddings.create(
  input: 'Hello, world!',
  model: 'embedding-3'
)

embedding = response.first_embedding
puts "Dimensions: #{embedding.length}"
puts "Tokens used: #{response.usage.total_tokens}"

# Multiple texts
response = client.embeddings.create(
  input: ['Hello', 'World', 'Z.ai'],
  model: 'embedding-3'
)

response.embeddings.each_with_index do |emb, idx|
  puts "Embedding #{idx}: #{emb.length} dimensions"
end

# Calculate similarity
def cosine_similarity(vec1, vec2)
  dot_product = vec1.zip(vec2).sum { |a, b| a * b }
  magnitude1 = Math.sqrt(vec1.sum { |a| a ** 2 })
  magnitude2 = Math.sqrt(vec2.sum { |a| a ** 2 })
  dot_product / (magnitude1 * magnitude2)
end

texts = ['Ruby is great', 'Python is awesome', 'I like pizza']
response = client.embeddings.create(input: texts, model: 'embedding-3')

sim = cosine_similarity(response.embeddings[0], response.embeddings[1])
puts "Similarity: #{sim.round(4)}"
```

### Images API

Generate images from text prompts:

```ruby
# Basic image generation
response = client.images.generate(
  prompt: 'A beautiful sunset over mountains',
  model: 'cogview-3'
)

puts response.first_url

# Generate multiple images
response = client.images.generate(
  prompt: 'A futuristic city',
  model: 'cogview-3',
  n: 2,                    # Number of images
  size: '1024x1024'        # Size: 256x256, 512x512, 1024x1024, etc.
)

response.urls.each_with_index do |url, idx|
  puts "Image #{idx + 1}: #{url}"
end

# Get base64 encoded image
response = client.images.generate(
  prompt: 'Abstract art',
  model: 'cogview-3',
  response_format: 'b64_json',
  size: '512x512'
)

image_data = Base64.decode64(response.base64_images.first)
File.binwrite('image.png', image_data)

# Using create alias
response = client.images.create(
  prompt: 'A cute robot',
  model: 'cogview-3'
)
```

### Files API

Manage files for fine-tuning and other purposes:

```ruby
# List files
files = client.files.list
files.data.each do |file|
  puts "#{file.filename} (#{file.bytes} bytes) - #{file.purpose}"
end

# Upload a file
file_content = JSON.generate([
  { prompt: 'Hello', completion: 'Hi!' },
  { prompt: 'Goodbye', completion: 'Bye!' }
])

uploaded = client.files.upload(
  file: file_content,
  purpose: 'fine-tune'    # fine-tune, assistants, batch, vision
)

puts "Uploaded: #{uploaded.id}"

# Retrieve file info
file = client.files.retrieve(uploaded.id)
puts "Status: #{file.status}"
puts "Size: #{file.bytes} bytes"

# Download file content
content = client.files.content(uploaded.id)
puts content

# Delete a file
result = client.files.delete(uploaded.id)
puts "Deleted: #{result.deleted?}"
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `api_key` | String | `ENV['ZAI_API_KEY']` | Your Z.ai API key |
| `base_url` | String | `'https://api.z.ai/api/paas/v4/'` | API base URL |
| `timeout` | Integer | `30` | Request timeout in seconds |
| `open_timeout` | Integer | `30` | Connection open timeout |
| `read_timeout` | Integer | `30` | Read timeout |
| `write_timeout` | Integer | `30` | Write timeout |
| `max_retries` | Integer | `3` | Max retry attempts |
| `retry_delay` | Integer | `1` | Delay between retries |
| `logger` | Logger | `nil` | Logger instance |
| `log_level` | Symbol | `:info` | Log level |
| `source_channel` | String | `'ruby-sdk'` | Source identifier |
| `disable_token_cache` | Boolean | `false` | Disable JWT caching |
| `custom_headers` | Hash | `{}` | Additional headers |
| `proxy_url` | String | `nil` | Proxy URL |

## Development

After checking out the repo, run:

```bash
$ bundle install
$ bundle exec rake spec
```

To run tests with coverage:

```bash
$ bundle exec rake coverage
```

To start an interactive console:

```bash
$ bundle exec rake console
```

## Testing

### Quick Verification

```bash
# Verify project structure (no dependencies required)
ruby test_standalone.rb

# Or run smoke test
ruby smoke_test.rb
```

### Full Test Suite

**Option 1: Docker Testing (Recommended)**
```bash
# Test in both Ruby and JRuby environments (Ruby 3.4.8 first, then JRuby)
./test_all_environments.sh docker

# Or test specific environment
./test_all_environments.sh ruby   # Ruby 3.4.8 only — fix issues here first
./test_all_environments.sh jruby  # JRuby 10.0.4.0 only — run after Ruby is green
```

**Option 2: Local Testing (RSpec)**

The SDK uses RSpec for testing. Run the test suite:

```bash
# Run all tests
$ bundle exec rspec

# Run specific test file
$ bundle exec rspec spec/resources/chat/completions_spec.rb

# Run with verbose output
$ bundle exec rspec --format documentation

# Run unit tests only
$ bundle exec rake spec_unit

# Run integration tests
$ bundle exec rake spec_integration
```

See [TESTING.md](TESTING.md) for detailed testing instructions.

## Examples

Check the [`examples/`](examples/) directory for runnable code samples. See [`examples/README.md`](examples/README.md) for a full index with difficulty levels and recommended reading order.

- `basic_chat.rb` - Basic chat completion examples _(Beginner)_
- `advanced_usage.rb` - Error handling, function calling, conversation management _(Intermediate)_
- `embeddings.rb` - Text embeddings, cosine similarity, document search _(Intermediate)_
- `images.rb` - Image generation with various sizes and formats _(Beginner)_
- `files.rb` - File upload, management, and lifecycle operations _(Intermediate)_
- `streaming_chat_examples.rb` - Real-time streaming patterns _(Intermediate)_
- `async_programming_examples.rb` - Concurrent API calls _(Advanced)_
- `batch_processing_examples.rb` - Batch operations _(Advanced)_
- `error_handling_examples.rb` - Comprehensive error patterns _(Intermediate)_
- `configuration_examples.rb` - All configuration options _(Beginner)_

## Tutorials

See the [`tutorials/`](tutorials/) folder for step-by-step project guides:

- [`01_first_chat_app.md`](tutorials/01_first_chat_app.md) - Build a CLI chatbot from scratch
- [`02_semantic_search.md`](tutorials/02_semantic_search.md) - Build document search using embeddings
- [`03_rails_integration.md`](tutorials/03_rails_integration.md) - Integrate Z.ai into a Rails app

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for solutions to common issues including authentication errors, timeouts, rate limiting, and Ruby version problems.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

## Code of Conduct

Everyone interacting in the Z.ai Ruby SDK project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Support

- Documentation: https://docs.z.ai
- API Reference: https://docs.z.ai/api
- Issues: https://github.com/zai-org/z-ai-sdk-ruby/issues

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Author

Jedt <sjedt@3ddaily.com>

## Acknowledgments

This SDK is inspired by and compatible with the Z.ai Python SDK, adapted for Ruby idioms and best practices.
