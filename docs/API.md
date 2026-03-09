# Z.ai Ruby SDK Documentation

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zai-ruby-sdk'
```

And then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install zai-ruby-sdk
```

## Quick Start

### Basic Usage

```ruby
require 'z/ai'

# Configure globally
Z::AI.configure do |config|
  config.api_key = ENV['ZAI_API_KEY']
end

# Create chat completion
response = Z::AI.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' },
    { role: 'user', content: 'Hello, Z.ai!' }
  ]
)

puts response.choices.first.message.content
```

### Using Client Instance

```ruby
client = Z::AI::Client.new(api_key: 'your-api-key')

response = client.chat.completions.create(
  model: 'glm-5',
  messages: [{ role: 'user', content: 'Hello!' }]
)

puts response.content
```

## Configuration

### Z::AI::Configuration

The main configuration class for managing SDK settings.

#### Attributes

- `api_key` (String) - Your Z.ai API key
- `base_url` (String) - API base URL (default: 'https://api.z.ai/api/paas/v4/')
- `timeout` (Integer) - Request timeout in seconds (default: 30)
- `open_timeout` (Integer) - Connection open timeout (default: 30)
- `read_timeout` (Integer) - Read timeout (default: 30)
- `write_timeout` (Integer) - Write timeout (default: 30)
- `max_retries` (Integer) - Maximum retry attempts (default: 3)
- `retry_delay` (Integer) - Delay between retries in seconds (default: 1)
- `logger` (Logger) - Logger instance
- `log_level` (Symbol) - Log level (:debug, :info, :warn, :error)
- `source_channel` (String) - Source identifier (default: 'ruby-sdk')
- `disable_token_cache` (Boolean) - Disable JWT token caching (default: false)
- `custom_headers` (Hash) - Additional headers
- `proxy_url` (String) - Proxy URL

#### Example

```ruby
Z::AI.configure do |config|
  config.api_key = 'your-api-key'
  config.timeout = 60
  config.max_retries = 5
  config.logger = Logger.new(STDOUT)
  config.log_level = :debug
end
```

## Client

### Z::AI::Client

Main client class for interacting with Z.ai APIs.

#### Methods

##### `initialize(config_or_options = {})`

Creates a new client instance.

**Parameters:**
- `config_or_options` - Configuration instance or hash of options

**Example:**

```ruby
# Using configuration object
config = Z::AI::Configuration.new
config.api_key = 'your-key'
client = Z::AI::Client.new(config)

# Using options hash
client = Z::AI::Client.new(
  api_key: 'your-key',
  timeout: 60
)
```

##### `chat`

Returns chat completions API instance.

**Returns:** `Z::AI::Resources::Chat::Completions`

**Example:**

```ruby
response = client.chat.completions.create(
  model: 'glm-5',
  messages: [{ role: 'user', content: 'Hello!' }]
)
```

##### `embeddings`

Returns embeddings API instance.

**Returns:** `Z::AI::Resources::Embeddings`

**Example:**

```ruby
response = client.embeddings.create(
  input: 'Hello, world!',
  model: 'embedding-3'
)
```

##### `images`

Returns images API instance.

**Returns:** `Z::AI::Resources::Images`

**Example:**

```ruby
response = client.images.generate(
  prompt: 'A beautiful sunset',
  model: 'cogview-3'
)
```

##### `files`

Returns files API instance.

**Returns:** `Z::AI::Resources::Files`

**Example:**

```ruby
files = client.files.list
uploaded = client.files.upload(file: content, purpose: 'fine-tune')
```

## Chat Completions API

### Z::AI::Resources::Chat::Completions

Provides access to chat completion operations.

#### Methods

##### `create(model:, messages:, stream: false, **options)`

Creates a chat completion.

**Parameters:**
- `model` (String, required) - Model name (e.g., 'glm-5')
- `messages` (Array, required) - Array of message objects
- `stream` (Boolean) - Enable streaming response (default: false)
- `temperature` (Float) - Sampling temperature (0.0-2.0)
- `max_tokens` (Integer) - Maximum tokens to generate
- `top_p` (Float) - Nucleus sampling parameter
- `presence_penalty` (Float) - Presence penalty (0.0-2.0)
- `frequency_penalty` (Float) - Frequency penalty (0.0-2.0)
- Additional options as supported by Z.ai API

**Returns:** `Z::AI::Models::Chat::Completion` or Enumerator (if streaming)

**Example:**

```ruby
# Basic completion
response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'system', content: 'You are helpful.' },
    { role: 'user', content: 'Hello!' }
  ],
  temperature: 0.7,
  max_tokens: 100
)

puts response.content

# Streaming completion
client.chat.completions.create(
  model: 'glm-5',
  messages: [{ role: 'user', content: 'Tell a story' }],
  stream: true
) do |chunk|
  print chunk.delta_content if chunk.delta_content
end
```

## Embeddings API

### Z::AI::Resources::Embeddings

Provides access to embedding operations.

#### Methods

##### `create(input:, model:, **options)`

Creates embeddings for text.

**Parameters:**
- `input` (String or Array, required) - Text or array of texts to embed
- `model` (String, required) - Embedding model (e.g., 'embedding-3')
- Additional options as supported by Z.ai API

**Returns:** `Z::AI::Models::Embeddings::Response`

**Example:**

```ruby
# Single text
response = client.embeddings.create(
  input: 'Hello, world!',
  model: 'embedding-3'
)

embedding = response.first_embedding
puts "Dimensions: #{embedding.length}"

# Multiple texts
response = client.embeddings.create(
  input: ['Hello', 'World'],
  model: 'embedding-3'
)

response.embeddings.each_with_index do |emb, idx|
  puts "Embedding #{idx}: #{emb.length} dimensions"
end
```

## Images API

### Z::AI::Resources::Images

Provides access to image generation operations.

#### Methods

##### `generate(prompt:, model: 'cogview-3', **options)`

Generates images from text prompts.

**Parameters:**
- `prompt` (String, required) - Text description of desired image
- `model` (String) - Image generation model (default: 'cogview-3')
- `n` (Integer) - Number of images to generate
- `size` (String) - Image size ('256x256', '512x512', '1024x1024')
- `response_format` (String) - Response format ('url' or 'b64_json')

**Returns:** `Z::AI::Models::Images::Response`

**Example:**

```ruby
# Generate single image
response = client.images.generate(
  prompt: 'A beautiful sunset over mountains',
  model: 'cogview-3',
  size: '1024x1024'
)

puts response.first_url

# Generate multiple images
response = client.images.generate(
  prompt: 'A futuristic city',
  model: 'cogview-3',
  n: 3
)

response.urls.each_with_index do |url, idx|
  puts "Image #{idx + 1}: #{url}"
end

# Get base64 image
response = client.images.generate(
  prompt: 'Abstract art',
  model: 'cogview-3',
  response_format: 'b64_json',
  size: '512x512'
)

image_data = Base64.decode64(response.base64_images.first)
File.binwrite('image.png', image_data)
```

## Files API

### Z::AI::Resources::Files

Provides access to file management operations.

#### Methods

##### `list`

Lists all uploaded files.

**Returns:** `Z::AI::Models::Files::ListResponse`

**Example:**

```ruby
files = client.files.list

files.data.each do |file|
  puts "#{file.filename} (#{file.bytes} bytes) - #{file.purpose}"
end
```

##### `upload(file:, purpose:)`

Uploads a file.

**Parameters:**
- `file` (String, required) - File content or path
- `purpose` (String, required) - File purpose ('fine-tune', 'assistants', 'batch', 'vision')

**Returns:** `Z::AI::Models::Files::FileInfo`

**Example:**

```ruby
# Upload from string
file_content = JSON.generate([
  { prompt: 'Hello', completion: 'Hi!' }
])

uploaded = client.files.upload(
  file: file_content,
  purpose: 'fine-tune'
)

puts "Uploaded: #{uploaded.id}"
```

##### `retrieve(file_id)`

Retrieves file information.

**Parameters:**
- `file_id` (String, required) - File ID

**Returns:** `Z::AI::Models::Files::FileInfo`

##### `content(file_id)`

Downloads file content.

**Parameters:**
- `file_id` (String, required) - File ID

**Returns:** String - File content

##### `delete(file_id)`

Deletes a file.

**Parameters:**
- `file_id` (String, required) - File ID

**Returns:** `Z::AI::Models::Files::DeleteResponse`

## Error Handling

The SDK provides comprehensive error handling:

### Error Hierarchy

- `Z::AI::Error` - Base error class
  - `Z::AI::APIStatusError` - API HTTP errors
    - `Z::AI::APIAuthenticationError` - Authentication failures (401, 403)
    - `Z::AI::APIRateLimitError` - Rate limit exceeded (429)
    - `Z::AI::APIResourceNotFoundError` - Resource not found (404)
    - `Z::AI::APIBadRequestError` - Invalid request (400)
    - `Z::AI::APIRequestFailedError` - Server errors (5xx)
    - `Z::AI::APITimeoutError` - Request timeout
  - `Z::AI::ConfigurationError` - Configuration errors
  - `Z::AI::ValidationError` - Input validation errors
  - `Z::AI::StreamingError` - Streaming errors
  - `Z::AI::JWTError` - JWT token errors
    - `Z::AI::JWTGenerationError` - Token generation failures

### Error Attributes

All errors include:
- `message` (String) - Error message
- `code` (String) - Error code
- `http_status` (Integer) - HTTP status code
- `http_body` (String) - Response body
- `headers` (Hash) - Response headers

### Example

```ruby
begin
  response = client.chat.completions.create(
    model: 'glm-5',
    messages: []
  )
rescue Z::AI::ValidationError => e
  puts "Validation error: #{e.message}"
rescue Z::AI::APIRateLimitError => e
  puts "Rate limited. Status: #{e.http_status}"
  sleep(60)
  retry
rescue Z::AI::APIStatusError => e
  puts "API error: #{e.message} (#{e.http_status})"
end
```

## Rails Integration

### Installation

Add to your Gemfile:

```ruby
gem 'zai-ruby-sdk'
```

Run the install generator:

```bash
rails generate z:ai:install
```

This creates:
- `config/z_ai.yml` - Configuration file
- `config/initializers/z_ai.rb` - Initializer

### Configuration

Edit `config/z_ai.yml`:

```yaml
development:
  api_key: <%= ENV['ZAI_API_KEY'] %>
  timeout: 60

production:
  api_key: <%= ENV['ZAI_API_KEY'] %>
  timeout: 30
```

### Usage in Controllers

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
  queue_as :default
  
  def perform(prompt)
    response = Z::AI.chat.completions.create(
      model: 'glm-5',
      messages: [{ role: 'user', content: prompt }]
    )
    
    # Process response
    User.find(user_id).update(response: response.content)
  end
end
```

## Streaming Responses

The SDK supports real-time streaming responses:

### Block-based Streaming

```ruby
client.chat.completions.create(
  model: 'glm-5',
  messages: [{ role: 'user', content: 'Tell a story' }],
  stream: true
) do |chunk|
  print chunk.delta_content if chunk.delta_content
end
```

### Enumerator-based Streaming

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

### Rails Streaming

```ruby
class StreamController < ApplicationController
  include ActionController::Live
  
  def create
    response.headers['Content-Type'] = 'text/event-stream'
    
    Z::AI.chat.completions.create(
      model: 'glm-5',
      messages: [{ role: 'user', content: params[:message] }],
      stream: true
    ) do |chunk|
      response.stream.write("data: #{chunk.delta_content}\n\n")
    end
    
  ensure
    response.stream.close
  end
end
```

## Authentication

### JWT Token Caching (Default)

The SDK automatically generates and caches JWT tokens:

```ruby
# JWT caching enabled (default)
client = Z::AI::Client.new(api_key: 'your-key.id.secret')

# Tokens are automatically cached and refreshed
response = client.chat.completions.create(...)
```

### Direct API Key

To use API key directly without JWT:

```ruby
client = Z::AI::Client.new(
  api_key: 'your-api-key',
  disable_token_cache: true
)
```

## Logging

### Enable Logging

```ruby
require 'logger'

Z::AI.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.log_level = :debug
end
```

### Log Levels

- `:debug` - Detailed request/response information
- `:info` - General information (default)
- `:warn` - Warnings only
- `:error` - Errors only

## Retry Logic

The SDK automatically retries failed requests:

### Configure Retry Behavior

```ruby
client = Z::AI::Client.new(
  api_key: 'your-key',
  max_retries: 5,     # Maximum retry attempts
  retry_delay: 2      # Delay between retries (seconds)
)
```

### Automatic Retry

Retries occur automatically for:
- Network timeouts
- Connection failures
- 5xx server errors

### No Retry

No retry for:
- Authentication errors (401, 403)
- Validation errors (400)
- Rate limiting (429) - must be handled manually

## Best Practices

### 1. Use Environment Variables

```bash
export ZAI_API_KEY="your-api-key"
export ZAI_BASE_URL="https://api.z.ai/api/paas/v4/"
```

```ruby
# Configuration automatically loaded from environment
client = Z::AI::Client.new
```

### 2. Handle Errors Gracefully

```ruby
begin
  response = client.chat.completions.create(...)
rescue Z::AI::APIRateLimitError => e
  sleep(60)
  retry
rescue Z::AI::ValidationError => e
  # Log and notify user
  Rails.logger.error "Validation: #{e.message}"
rescue Z::AI::Error => e
  # Generic error handling
  Rails.logger.error "Z.ai error: #{e.message}"
end
```

### 3. Use Background Jobs for Long Requests

```ruby
# Don't block web requests
AiJob.perform_later(params[:prompt])
```

### 4. Cache Responses When Appropriate

```ruby
Rails.cache.fetch("ai_response/#{prompt_hash}", expires_in: 1.hour) do
  client.chat.completions.create(
    model: 'glm-5',
    messages: [{ role: 'user', content: prompt }]
  ).content
end
```

### 5. Monitor Performance

```ruby
ActiveSupport::Notifications.subscribe('request.z_ai') do |name, start, finish, id, payload|
  duration = (finish - start) * 1000
  Rails.logger.info "Z.ai request took #{duration}ms"
end
```

## Support

- **Documentation**: https://docs.z.ai
- **API Reference**: https://docs.z.ai/api
- **GitHub Issues**: https://github.com/Jedt3D/z-ai-sdk-ruby/issues
- **Email**: sjedt@3ddaily.com

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

## Version

Current version: **0.1.0**