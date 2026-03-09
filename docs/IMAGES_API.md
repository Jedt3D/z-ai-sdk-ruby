# Images API

## Overview

The Images API generates images from text descriptions using Z.ai's image generation models.

## Quick Start

```ruby
client = Z::AI::Client.new(api_key: 'your-api-key')

response = client.images.generate(
  prompt: 'A beautiful sunset over mountains',
  model: 'cogview-3'
)

puts response.first_url
```

## Methods

### generate / create

Generates images from text prompts.

**Signature:**

```ruby
def generate(prompt:, model: 'cogview-3', **options)
alias create generate
```

**Parameters:**

- `prompt` (String, required) - Text description of desired image
- `model` (String, optional) - Model to use (default: 'cogview-3')
- `**options` (Hash) - Additional parameters

**Additional Options:**

- `n` (Integer) - Number of images to generate (1-4)
- `size` (String) - Image size ('256x256', '512x512', '1024x1024')
- `response_format` (String) - Response format ('url' or 'b64_json')
- `quality` (String) - Quality setting ('standard' or 'hd')

**Returns:** `Z::AI::Models::Images::Response`

**Example:**

```ruby
# Basic usage
response = client.images.generate(
  prompt: 'A futuristic city skyline',
  model: 'cogview-3'
)

# Multiple images
response = client.images.generate(
  prompt: 'A cute robot',
  model: 'cogview-3',
  n: 2
)

# Base64 format
response = client.images.generate(
  prompt: 'Abstract art',
  model: 'cogview-3',
  response_format: 'b64_json'
)
```

## Response Object

```ruby
response.created     # => Unix timestamp
response.data        # => Array of ImageData objects
response.urls        # => Array of image URLs
response.first_url   # => First image URL
response.base64_images # => Array of base64 images
```

## Available Models

- `cogview-3` - Latest image generation model
- `cogview-2` - Previous generation model

## Image Sizes

Supported sizes:
- 256x256
- 512x512
- 1024x1024
- 1792x1792
- 1024x1792
- 1792x1024

## Examples

### Basic Generation

```ruby
response = client.images.generate(
  prompt: 'A serene lake at sunset',
  model: 'cogview-3',
  size: '1024x1024'
)

puts response.first_url
```

### Save to File

```ruby
response = client.images.generate(
  prompt: 'A mountain landscape',
  model: 'cogview-3',
  response_format: 'b64_json'
)

image_data = Base64.decode64(response.base64_images.first)
File.binwrite('landscape.png', image_data)
```

### Generate Multiple Images

```ruby
response = client.images.generate(
  prompt: 'A colorful abstract painting',
  model: 'cogview-3',
  n: 4
)

response.urls.each_with_index do |url, idx|
  puts "Image #{idx + 1}: #{url}"
end
```

## Best Practices

1. **Use Descriptive Prompts**: More detail = better results
2. **Choose Appropriate Size**: Balance quality vs speed
3. **Handle Content Policy**: Some prompts may be rejected
4. **Cache Generated Images**: Store URLs or images locally

## Error Handling

```ruby
begin
  response = client.images.generate(
    prompt: 'A peaceful scene',
    model: 'cogview-3'
  )
rescue Z::AI::ValidationError => e
  puts "Invalid prompt: #{e.message}"
rescue Z::AI::Error => e
  puts "Image generation failed: #{e.message}"
end
```

## See Also

- [Chat API](CHAT_API.md)
- [Configuration](CONFIGURATION.md)
