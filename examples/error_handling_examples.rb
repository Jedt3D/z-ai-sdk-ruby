# frozen_string_literal: true

require_relative '../lib/z/ai'

# Configure API key
client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here'
)

puts "Error Handling and Retry Logic Examples"
puts "=" * 50

begin
  # Example 1: Invalid Request Error
  puts "\n1. Testing Invalid Request (Empty Messages)..."
  client.chat.completions.create(
    model: 'glm-5',
    messages: []  # This should cause an error
  )
rescue Z::AI::ValidationError => e
  puts "✓ Caught ValidationError: #{e.message}"
  puts "  Error details: #{e.code || 'No code'}"
  puts "  HTTP Status: #{e.http_status || 'No HTTP status'}"
rescue => e
  puts "✗ Unexpected error: #{e.class} - #{e.message}"
end

begin
  # Example 2: Authentication Error
  puts "\n2. Testing Authentication Error..."
  bad_client = Z::AI::Client.new(api_key: 'invalid-key')
  bad_client.chat.completions.create(
    model: 'glm-5',
    messages: [{ role: 'user', content: 'Hello' }]
  )
rescue Z::AI::APIAuthenticationError => e
  puts "✓ Caught AuthenticationError: #{e.message}"
  puts "  HTTP Status: #{e.http_status}"
rescue => e
  puts "✗ Unexpected error: #{e.class} - #{e.message}"
end

begin
  # Example 3: Rate Limit Error
  puts "\n3. Testing Rate Limit (Simulated)..."
  # This will trigger rate limiting if you make many rapid requests
  5.times do |i|
    begin
      client.chat.completions.create(
        model: 'glm-5',
        messages: [{ role: 'user', content: "Request #{i}" }]
      )
      puts "  Request #{i + 1}: Success"
    rescue Z::AI::APIRateLimitError => e
      puts "  Request #{i + 1}: Rate limited - #{e.message}"
      break
    rescue => e
      puts "  Request #{i + 1}: Error - #{e.class}"
    end
  end
rescue => e
  puts "✗ Unexpected error: #{e.class} - #{e.message}"
end

begin
  # Example 4: Server Error Handling
  puts "\n4. Testing Server Error Resilience..."
  client_with_retries = Z::AI::Client.new(
    api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here',
    max_retries: 3,
    retry_delay: 2
  )
  
  response = client_with_retries.chat.completions.create(
    model: 'glm-5',
    messages: [{ role: 'user', content: 'Test server error resilience' }]
  )
  
  puts "✓ Request succeeded with retries"
  puts "  Response: #{response.content[0..50]}#{'...' if response.content.length > 50}"
rescue Z::AI::APITimeoutError => e
  puts "✓ Caught TimeoutError: #{e.message}"
  puts "  The request was retried #{client_with_retries.max_retries} times"
rescue => e
  puts "✗ Unexpected error: #{e.class} - #{e.message}"
end

# Example 5: Error Recovery with Fallback
puts "\n5. Testing Error Recovery with Fallback..."

def chat_with_fallback(message, max_retries = 2)
  retries = 0
  begin
    response = client.chat.completions.create(
      model: 'glm-5',
      messages: [{ role: 'user', content: message }],
      temperature: 0.7
    )
    return response
  rescue Z::AI::APIRateLimitError => e
    retries += 1
    if retries <= max_retries
      puts "  Rate limited, retry #{retries}/#{max_retries}... Waiting..."
      sleep(2 ** retries)  # Exponential backoff
      retry
    else
      # Fallback to simpler model
      puts "  Max retries reached, falling back to simpler model..."
      return client.chat.completions.create(
        model: 'glm-4',  # Simpler model might have different limits
        messages: [{ role: 'user', content: message }],
        temperature: 0.3
      )
    end
  rescue => e
    puts "  Unexpected error in retry #{retries}: #{e.class} - #{e.message}"
    raise
  end
end

begin
  fallback_response = chat_with_fallback(
    "Generate a simple poem about programming",
    3
  )
  puts "✓ Response with fallback: #{fallback_response.content[0..80]}#{'...' if fallback_response.content.length > 80}"
rescue => e
  puts "✗ Fallback failed: #{e.class} - #{e.message}"
end

# Example 6: Batch Error Handling
puts "\n6. Testing Batch Error Handling..."

requests = [
  { role: 'user', content: 'What is Ruby?' },
  { role: 'user', content: 'What is Python?' },
  { role: 'user', content: 'What is JavaScript?' }
]

results = []
errors = []

requests.each_with_index do |request, index|
  begin
    response = client.chat.completions.create(
      model: 'glm-5',
      messages: [{ role: 'user', content: request[:content] }],
      max_tokens: 100
    )
    results[index] = response.content
    puts "  Request #{index + 1}: Success"
  rescue Z::AI::ValidationError => e
    errors[index] = "Validation error: #{e.message}"
    puts "  Request #{index + 1}: #{e.class} - #{e.message}"
  rescue Z::AI::APIRateLimitError => e
    errors[index] = "Rate limited: #{e.message}"
    puts "  Request #{index + 1}: #{e.class} - Rate limiting"
    sleep(1)  # Wait before next request
  rescue => e
    errors[index] = "Unexpected error: #{e.class} - #{e.message}"
    puts "  Request #{index + 1}: #{e.class} - #{e.message}"
  end
end

puts "\nBatch Results Summary:"
puts "Successful requests: #{results.compact.length}"
puts "Failed requests: #{errors.length}"
puts "Success rate: #{(results.compact.length.to_f / requests.length * 100).round(1)}%"

# Example 7: Comprehensive Error Logging
puts "\n7. Testing Comprehensive Error Logging..."

# Configure client with logging
client_with_logging = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here',
  logger: Logger.new($stdout),
  log_level: :debug
)

begin
  puts "  Making request with debug logging..."
  response = client_with_logging.chat.completions.create(
    model: 'glm-5',
    messages: [{ role: 'user', content: 'Test error logging' }]
  )
  puts "✓ Request completed successfully"
rescue Z::AI::APIStatusError => e
  puts "✓ API Status Error caught and logged"
  puts "  Full error details available in debug logs"
rescue => e
  puts "✗ Unexpected error type: #{e.class}"
end

puts "\nError Handling Examples Complete!"
puts "Key takeaways:"
puts "1. Always catch specific error types for better handling"
puts "2. Implement retry logic with exponential backoff"
puts "3. Use fallback strategies for critical operations"
puts "4. Log errors appropriately for debugging"
puts "5. Gracefully degrade functionality when errors occur"