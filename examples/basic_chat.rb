# frozen_string_literal: true

require_relative '../lib/z/ai'

client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here'
)

puts "Example 1: Basic Chat Completion"
puts "=" * 50

response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' },
    { role: 'user', content: 'Hello, Z.ai! Can you tell me a short joke?' }
  ]
)

puts "Response ID: #{response.id}"
puts "Model: #{response.model}"
puts "Content: #{response.content}"
puts "Tokens used: #{response.usage&.total_tokens}"
puts "\n"

puts "Example 2: Streaming Response"
puts "=" * 50

print "Streaming: "
client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'Count from 1 to 5' }
  ],
  stream: true
) do |chunk|
  content = chunk.delta_content
  print content if content
end
puts "\n\n"

puts "Example 3: Multi-turn Conversation"
puts "=" * 50

messages = [
  { role: 'user', content: 'My name is Alice' },
  { role: 'assistant', content: 'Hello Alice! Nice to meet you.' },
  { role: 'user', content: 'What is my name?' }
]

response = client.chat.completions.create(
  model: 'glm-5',
  messages: messages
)

puts "Response: #{response.content}"
puts "\n"

puts "Example 4: Using Message Objects"
puts "=" * 50

system_msg = Z::AI::Models::Chat::Message.new(
  role: 'system',
  content: 'You are a code reviewer. Be concise.'
)

user_msg = Z::AI::Models::Chat::Message.new(
  role: 'user',
  content: 'Review this code: def add(a, b) a + b end'
)

response = client.chat.completions.create(
  model: 'glm-5',
  messages: [system_msg, user_msg]
)

puts "Code Review: #{response.content}"
puts "\n"

puts "Example 5: Temperature and Other Parameters"
puts "=" * 50

response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'Generate a creative name for a tech startup' }
  ],
  temperature: 0.9,
  max_tokens: 50,
  top_p: 0.95
)

puts "Startup Name: #{response.content}"
