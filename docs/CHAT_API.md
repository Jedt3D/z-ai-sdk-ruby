# Chat Completions API

## Overview

The Chat Completions API allows you to generate text responses using Z.ai's language models.

## Installation

```ruby
require 'z/ai'
```

## Quick Start

```ruby
client = Z::AI::Client.new(api_key: 'your-api-key')

response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' },
    { role: 'user', content: 'Hello!' }
  ]
)

puts response.choices.first.message.content
```

## Methods

### create

Creates a chat completion.

**Signature:**

```ruby
def create(model:, messages:, stream: false, **options)
```

**Parameters:**

- `model` (String, required) - Model to use (e.g., 'glm-5', 'glm-4.7', 'glm-4')
- `messages` (Array, required) - Array of message objects
- `stream` (Boolean, optional) - Enable streaming response
- `**options` (Hash) - Additional parameters

**Additional Options:**

- `temperature` (Float) - Sampling temperature (0.0 - 2.0)
- `max_tokens` (Integer) - Maximum tokens to generate
- `top_p` (Float) - Nucleus sampling parameter
- `presence_penalty` (Float) - Presence penalty (0.0 - 2.0)
- `frequency_penalty` (Float) - Frequency penalty (0.0 - 2.0)
- `stop` (Array) - Stop sequences
- `tools` (Array) - Tool definitions
- `tool_choice` (String/Hash) - Tool choice strategy

**Returns:**

- Non-streaming: `Z::AI::Models::Chat::Completion`
- Streaming: `Enumerator` or yields chunks to block

**Example:**

```ruby
# Basic completion
response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'What is Ruby?' }
  ]
)

puts response.content
```

## Streaming

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

## Message Format

### Text Messages

```ruby
{ role: 'system', content: 'You are a helpful assistant.' }
{ role: 'user', content: 'Hello!' }
{ role: 'assistant', content: 'Hi! How can I help?' }
```

### Multimodal Messages

```ruby
{
  role: 'user',
  content: [
    { type: 'text', text: 'What is in this image?' },
    {
      type: 'image_url',
      image_url: {
        url: 'data:image/jpeg;base64,...'
      }
    }
  ]
}
```

### Tool Calls

```ruby
{
  role: 'assistant',
  content: nil,
  tool_calls: [
    {
      id: 'call_123',
      type: 'function',
      function: {
        name: 'get_weather',
        arguments: '{"location": "Boston"}'
      }
    }
  ]
}
```

## Response Object

### Completion Object

```ruby
response.id              # => "chatcmpl-123456"
response.object          # => "chat.completion"
response.created         # => 1234567890 (timestamp)
response.model           # => "glm-5"
response.choices         # => Array of Choice objects
response.usage           # => Usage object
```

### Choice Object

```ruby
choice.index             # => 0
choice.message           # => Message object
choice.finish_reason     # => "stop"
```

### Message Object

```ruby
message.role             # => "assistant"
message.content          # => "Hello! How can I help?"
message.tool_calls       # => Array of tool calls (optional)
```

### Usage Object

```ruby
usage.prompt_tokens      # => 15
usage.completion_tokens  # => 25
usage.total_tokens       # => 40
```

## Advanced Usage

### With Parameters

```ruby
response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'Generate creative text' }
  ],
  temperature: 0.9,
  max_tokens: 100,
  top_p: 0.95,
  presence_penalty: 0.6,
  frequency_penalty: 0.3
)
```

### Multi-turn Conversation

```ruby
messages = [
  { role: 'system', content: 'You are a helpful coding assistant.' },
  { role: 'user', content: 'How do I read a file in Ruby?' },
  { role: 'assistant', content: 'You can use File.read...' },
  { role: 'user', content: 'What about writing?' }
]

response = client.chat.completions.create(
  model: 'glm-5',
  messages: messages
)
```

### Function Calling

```ruby
tools = [
  {
    type: 'function',
    function: {
      name: 'get_weather',
      description: 'Get current weather',
      parameters: {
        type: 'object',
        properties: {
          location: {
            type: 'string',
            description: 'City name'
          }
        },
        required: ['location']
      }
    }
  }
]

response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'What is the weather in Boston?' }
  ],
  tools: tools,
  tool_choice: 'auto'
)
```

## Error Handling

```ruby
begin
  response = client.chat.completions.create(
    model: 'glm-5',
    messages: []
  )
rescue Z::AI::ValidationError => e
  puts "Validation error: #{e.message}"
rescue Z::AI::APIRateLimitError => e
  puts "Rate limited. Wait and retry."
  sleep(60)
  retry
rescue Z::AI::Error => e
  puts "API error: #{e.message}"
end
```

## Models

### Available Models

- `glm-5` - Latest flagship model
- `glm-4.7` - Advanced reasoning model
- `glm-4` - General purpose model
- `glm-4.6v` - Vision model (multimodal)
- `charglm-3` - Character role-playing model

### Model Selection

```ruby
# Fast, simple tasks
response = client.chat.completions.create(
  model: 'glm-4',
  messages: [...]
)

# Complex reasoning
response = client.chat.completions.create(
  model: 'glm-4.7',
  messages: [...]
)

# Vision tasks
response = client.chat.completions.create(
  model: 'glm-4.6v',
  messages: [
    {
      role: 'user',
      content: [
        { type: 'text', text: 'Describe this image' },
        { type: 'image_url', image_url: { url: 'data:image/jpeg;base64,...' } }
      ]
    }
  ]
)
```

## Best Practices

### 1. Set System Messages

```ruby
messages = [
  { role: 'system', content: 'You are a helpful Ruby programming expert.' },
  { role: 'user', content: 'How do I create a class?' }
]
```

### 2. Use Appropriate Temperature

```ruby
# Factual responses (low temperature)
temperature: 0.3

# Creative writing (high temperature)  
temperature: 0.9

# Balanced responses
temperature: 0.7
```

### 3. Limit Token Usage

```ruby
response = client.chat.completions.create(
  model: 'glm-5',
  messages: [...],
  max_tokens: 100  # Prevent overly long responses
)
```

### 4. Stream for Better UX

```ruby
# For long responses, use streaming
client.chat.completions.create(
  model: 'glm-5',
  messages: [{ role: 'user', content: 'Write a long story' }],
  stream: true
) do |chunk|
  print chunk.delta_content  # Show progress to user
end
```

## Rails Integration

### In Controllers

```ruby
class ChatController < ApplicationController
  def create
    response = Z::AI.chat.completions.create(
      model: 'glm-5',
      messages: [
        { role: 'user', content: params[:message] }
      ]
    )
    
    render json: { response: response.content }
  end
end
```

### In Background Jobs

```ruby
class AiJob < ApplicationJob
  def perform(prompt)
    response = Z::AI.chat.completions.create(
      model: 'glm-5',
      messages: [{ role: 'user', content: prompt }]
    )
    
    # Process response...
  end
end
```

## See Also

- [Embeddings API](EMBEDDINGS.md)
- [Images API](IMAGES.md)
- [Files API](FILES.md)
- [Configuration](CONFIGURATION.md)