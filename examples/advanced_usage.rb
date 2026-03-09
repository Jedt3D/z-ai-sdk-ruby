# frozen_string_literal: true

require_relative '../lib/z/ai'

puts "Advanced Examples: Error Handling and Multimodal"
puts "=" * 60

client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here'
)

puts "\nExample 1: Error Handling"
puts "-" * 60

begin
  client.chat.completions.create(
    model: 'glm-5',
    messages: []
  )
rescue Z::AI::ValidationError => e
  puts "Validation Error: #{e.message}"
rescue Z::AI::APIAuthenticationError => e
  puts "Authentication Error: #{e.message}"
  puts "HTTP Status: #{e.http_status}"
rescue Z::AI::APIRateLimitError => e
  puts "Rate Limit Error: #{e.message}"
  puts "Please wait before making more requests"
rescue Z::AI::APIStatusError => e
  puts "API Error: #{e.message}"
  puts "Status: #{e.http_status}"
  puts "Code: #{e.code}"
rescue Z::AI::Error => e
  puts "General Error: #{e.message}"
end

puts "\nExample 2: Retry Logic"
puts "-" * 60

max_retries = 3
retry_count = 0

begin
  retry_count += 1
  puts "Attempt #{retry_count}/#{max_retries}"
  
  response = client.chat.completions.create(
    model: 'glm-5',
    messages: [{ role: 'user', content: 'Hello' }]
  )
  
  puts "Success: #{response.content}"
  
rescue Z::AI::APITimeoutError, Z::AI::APIConnectionError => e
  if retry_count < max_retries
    puts "Request failed: #{e.message}. Retrying..."
    sleep(2 ** retry_count)
    retry
  else
    puts "Failed after #{max_retries} attempts"
  end
end

puts "\nExample 3: Multimodal Chat (Vision)"
puts "-" * 60

if File.exist?('examples/test_image.jpg')
  image_data = File.read('examples/test_image.jpg')
  encoded_image = Base64.strict_encode64(image_data)
  
  response = client.chat.completions.create(
    model: 'glm-4v-plus',
    messages: [
      {
        role: 'user',
        content: [
          { type: 'text', text: 'What do you see in this image?' },
          {
            type: 'image_url',
            image_url: {
              url: "data:image/jpeg;base64,#{encoded_image}"
            }
          }
        ]
      }
    ]
  )
  
  puts "Image Description: #{response.content}"
else
  puts "Skipping multimodal example - test image not found"
  puts "To test multimodal capabilities, place an image at examples/test_image.jpg"
end

puts "\nExample 4: Function Calling (Tool Use)"
puts "-" * 60

functions = [
  {
    name: 'get_weather',
    description: 'Get the current weather in a location',
    parameters: {
      type: 'object',
      properties: {
        location: {
          type: 'string',
          description: 'City and country, e.g., "Paris, France"'
        }
      },
      required: ['location']
    }
  }
]

response = client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'What is the weather in Tokyo?' }
  ],
  functions: functions,
  function_call: 'auto'
)

choice = response.choices.first
if choice.message.function_call
  function_name = choice.message.function_call['name']
  function_args = JSON.parse(choice.message.function_call['arguments'])
  
  puts "Function called: #{function_name}"
  puts "Arguments: #{function_args}"
  
  puts "\nSimulating function execution..."
  weather_result = { temperature: 22, condition: 'Sunny', location: function_args['location'] }
  
  messages = [
    { role: 'user', content: 'What is the weather in Tokyo?' },
    choice.message.to_h,
    {
      role: 'function',
      name: function_name,
      content: weather_result.to_json
    }
  ]
  
  final_response = client.chat.completions.create(
    model: 'glm-5',
    messages: messages
  )
  
  puts "Final Response: #{final_response.content}"
else
  puts "No function call made"
  puts "Response: #{response.content}"
end

puts "\nExample 5: Conversation with Context Management"
puts "-" * 60

class ConversationManager
  def initialize(client, model: 'glm-5', max_tokens: 4000)
    @client = client
    @model = model
    @max_tokens = max_tokens
    @messages = []
  end
  
  def add_message(role, content)
    @messages << { role: role, content: content }
    trim_messages_if_needed
  end
  
  def get_response(user_message)
    add_message('user', user_message)
    
    response = @client.chat.completions.create(
      model: @model,
      messages: @messages
    )
    
    assistant_message = response.content
    add_message('assistant', assistant_message)
    
    assistant_message
  end
  
  private
  
  def trim_messages_if_needed
    while @messages.length > 20
      @messages.shift
      puts "[Context trimmed to last 20 messages]"
    end
  end
end

conv = ConversationManager.new(client)
puts "AI: #{conv.get_response('Hello! My name is Bob.')}"
puts "AI: #{conv.get_response('What is my name?')}"
puts "AI: #{conv.get_response('Tell me about yourself.')}"

puts "\n" + "=" * 60
puts "Examples completed!"
