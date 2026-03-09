# Quick Start Guide - Z.ai Ruby SDK

This guide will help you get started with the Z.ai Ruby SDK quickly.

## Installation

### 1. Install the Gem

Add to your Gemfile:

```ruby
gem 'zai-ruby-sdk'
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install zai-ruby-sdk
```

### 2. Get Your API Key

Get your API key from [Z.ai Dashboard](https://console.z.ai)

### 3. Set Environment Variable

```bash
export ZAI_API_KEY='your-api-key-here'
```

## Basic Usage

### Quick Example

```ruby
require 'z/ai'

# Create client (uses ZAI_API_KEY environment variable)
client = Z::AI::Client.new

# Create a chat completion
response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'Hello, Z.ai!' }
  ]
)

puts response.content
# => "Hello! How can I help you today?"
```

### Configuration

```ruby
# Option 1: Environment variable
ENV['ZAI_API_KEY'] = 'your-api-key'
client = Z::AI::Client.new

# Option 2: Direct configuration
client = Z::AI::Client.new(
  api_key: 'your-api-key',
  timeout: 30,
  max_retries: 3
)

# Option 3: Global configuration
Z::AI.configure do |config|
  config.api_key = 'your-api-key'
  config.timeout = 60
  config.logger = Logger.new(STDOUT)
end

# Then use without instantiating
Z::AI.chat.completions.create(...)
```

## Common Use Cases

### 1. Chat Completions

```ruby
# Simple chat
response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'system', content: 'You are a helpful assistant' },
    { role: 'user', content: 'What is Ruby?' }
  ]
)

puts response.content
```

### 2. Streaming Responses

```ruby
# Stream response in real-time
client.chat.completions.create(
  model: 'glm-5',
  messages: [{ role: 'user', content: 'Tell me a story' }],
  stream: true
) do |chunk|
  print chunk.delta_content if chunk.delta_content
end
```

### 3. Text Embeddings

```ruby
# Get embeddings for text
response = client.embeddings.create(
  input: 'Hello, world!',
  model: 'embedding-3'
)

embedding = response.first_embedding
puts "Dimensions: #{embedding.length}"
```

### 4. Image Generation

```ruby
# Generate image from text
response = client.images.generate(
  prompt: 'A sunset over mountains',
  model: 'cogview-3',
  size: '1024x1024'
)

puts response.first_url
# => "https://example.com/generated-image.png"
```

### 5. File Management

```ruby
# Upload a file
content = '{"prompt": "Hello", "completion": "Hi!"}'
file = client.files.upload(
  file: content,
  purpose: 'fine-tune'
)

# List files
files = client.files.list
files.data.each do |f|
  puts "#{f.filename} - #{f.bytes} bytes"
end
```

## Error Handling

```ruby
begin
  response = client.chat.completions.create(
    model: 'glm-5',
    messages: []
  )
rescue Z::AI::ValidationError => e
  puts "Invalid input: #{e.message}"
rescue Z::AI::APIAuthenticationError => e
  puts "Auth failed: #{e.message}"
rescue Z::AI::APIRateLimitError => e
  puts "Rate limited. Wait and retry."
rescue Z::AI::Error => e
  puts "Error: #{e.message}"
end
```

## Advanced Configuration

```ruby
client = Z::AI::Client.new(
  api_key: 'your-key',
  base_url: 'https://custom.endpoint/',  # Custom endpoint
  timeout: 60,                           # Request timeout
  max_retries: 5,                        # Retry attempts
  retry_delay: 2,                        # Delay between retries
  logger: Logger.new(STDOUT),            # Enable logging
  log_level: :debug,                     # Log level
  proxy_url: 'http://proxy:8080'        # Use proxy
)
```

## Using with Rails

### Initializer

Create `config/initializers/z_ai.rb`:

```ruby
Z::AI.configure do |config|
  config.api_key = Rails.application.credentials.zai_api_key
  config.logger = Rails.logger
  config.log_level = Rails.env.production? ? :info : :debug
end
```

### In Controllers

```ruby
class ChatController < ApplicationController
  def create
    response = Z::AI.chat.completions.create(
      model: 'glm-5',
      messages: [{ role: 'user', content: params[:message] }]
    )
    
    render json: { response: response.content }
  end
end
```

### Background Jobs

```ruby
class AiJob < ApplicationJob
  def perform(prompt)
    response = Z::AI.chat.completions.create(
      model: 'glm-5',
      messages: [{ role: 'user', content: prompt }]
    )
    
    # Process response
    response.content
  end
end
```

## Testing

### Mock API Responses

```ruby
# In spec_helper.rb
require 'webmock/rspec'

# In your test
before do
  stub_request(:post, 'https://api.z.ai/api/paas/v4/chat/completions')
    .to_return(
      status: 200,
      body: {
        id: 'test-id',
        choices: [{ message: { content: 'Test response' } }]
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
end

it 'creates a chat completion' do
  response = client.chat.completions.create(
    model: 'glm-5',
    messages: [{ role: 'user', content: 'Test' }]
  )
  
  expect(response.content).to eq('Test response')
end
```

## Next Steps

- Read the [API Documentation](README.md#api-reference)
- Check out [Examples](examples/)
- Review [Error Handling](README.md#error-handling)
- See [Configuration Options](README.md#configuration-options)

## Getting Help

- 📖 [Documentation](README.md)
- 🐛 [Issue Tracker](https://github.com/zai-org/z-ai-sdk-ruby/issues)
- 💬 [Discussions](https://github.com/zai-org/z-ai-sdk-ruby/discussions)
- 📧 Email: sjedt@3ddaily.com

## Resources

- [Z.ai Official Documentation](https://docs.z.ai)
- [API Reference](https://docs.z.ai/api)
- [Ruby Style Guide](https://rubystyle.guide)

---

Happy coding with Z.ai! 🚀
