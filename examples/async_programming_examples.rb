# frozen_string_literal: true

require_relative '../lib/z/ai'

puts "Async Programming and Concurrency Examples"
puts "=" * 50

# Configure client
client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here',
  timeout: 30
)

# Example 1: Thread-based Concurrent Requests
puts "\n1. Thread-based Concurrent Processing..."
puts "-" * 30

def concurrent_chat_requests(prompt_list)
  threads = []
  results = []
  mutex = Mutex.new
  
  prompt_list.each_with_index do |prompt, index|
    threads << Thread.new do
      begin
        response = client.chat.completions.create(
          model: 'glm-5',
          messages: [{ role: 'user', content: prompt }],
          max_tokens: 100
        )
        
        mutex.synchronize do
          results[index] = { 
            prompt: prompt, 
            response: response.content, 
            tokens: response.usage.total_tokens,
            thread_id: Thread.current.object_id
          }
        end
      rescue => e
        mutex.synchronize do
          results[index] = { 
            prompt: prompt, 
            error: e.message, 
            thread_id: Thread.current.object_id
          }
        end
      end
    end
  end
  
  # Wait for all threads to complete
  threads.each(&:join)
  results
end

# Test concurrent requests
prompts = [
  "What is Ruby programming?",
  "Explain machine learning briefly",
  "Write a haiku about coding"
]

start_time = Time.now
results = concurrent_chat_requests(prompts)
end_time = Time.now

puts "Concurrent Results:"
successful_results = results.select { |r| r[:response] }
failed_results = results.select { |r| r[:error] }

successful_results.each do |result|
  puts "✓ Thread #{result[:thread_id]}: #{result[:prompt][0..30]}..."
  puts "  Response: #{result[:response][0..60]}..."
  puts "  Tokens: #{result[:tokens]}"
end

failed_results.each do |result|
  puts "✗ Thread #{result[:thread_id]}: #{result[:prompt][0..30]}..."
  puts "  Error: #{result[:error]}"
end

puts "\nExecution time: #{end_time - start_time} seconds"
puts "Success rate: #{(successful_results.length.to_f / prompts.length * 100).round(1)}%"

# Example 2: Fiber-based Processing with Enumerator
puts "\n2. Fiber-based Processing with Enumerator..."
puts "-" * 30

def fiber_chat_generator(prompt_list)
  fiber_results = []
  
  prompt_list.each do |prompt|
    fiber = Fiber.new do
      begin
        response = client.chat.completions.create(
          model: 'glm-5',
          messages: [{ role: 'user', content: prompt }],
          max_tokens: 80
        )
        Fiber.yield({ prompt: prompt, response: response.content })
      rescue => e
        Fiber.yield({ prompt: prompt, error: e.message })
      end
    end
    
    result = fiber.resume
    fiber_results << result
  end
  
  fiber_results
end

# Create an enumerator for fiber-based processing
fiber_enumerator = Enumerator.new do |yielder|
  prompts = [
    "Generate a random programming fact",
    "Explain a concept in simple terms", 
    "Create a code snippet example"
  ]
  
  results = fiber_chat_generator(prompts)
  results.each { |result| yielder.yield(result) }
end

puts "Fiber-based Results:"
fiber_enumerator.each_with_index do |result, index|
  if result[:error]
    puts "✗ Fiber #{index + 1}: Error - #{result[:error]}"
  else
    puts "✓ Fiber #{index + 1}: #{result[:prompt][0..40]}..."
    puts "  #{result[:response][0..70]}..."
  end
end

# Example 3: Async Stream Processing with Background Threads
puts "\n3. Async Stream Processing..."
puts "-" * 30

def process_stream_async(prompt, &callback)
  Thread.new do
    begin
      chunks = []
      
      client.chat.completions.create(
        model: 'glm-5',
        messages: [{ role: 'user', content: prompt }],
        stream: true
      ) do |chunk|
        if chunk.delta_content
          chunks << chunk.delta_content
          callback.call(chunk) if callback
        end
      end
      
      puts "Stream completed for: #{prompt[0..30]}..."
      puts "Total chunks received: #{chunks.length}"
    rescue => e
      puts "Stream error for #{prompt[0..30]}: #{e.message}"
    end
  end
end

# Process multiple streaming requests concurrently
stream_prompts = [
  "Write a short story about AI",
  "Explain quantum computing simply",
  "Create a recipe for debugging code"
]

stream_threads = []

stream_prompts.each_with_index do |prompt, index|
  thread = process_stream_async(prompt) do |chunk|
    puts "[Stream #{index + 1}] Chunk: #{chunk.delta_content[0..30]}..." if chunk.delta_content
  end
  
  stream_threads << thread
end

# Wait for all streaming threads to complete
stream_threads.each(&:join)

# Example 4: Concurrent Embeddings Processing
puts "\n4. Concurrent Embeddings Processing..."
puts "-" * 30

def concurrent_embeddings(texts)
  threads = []
  embeddings = []
  mutex = Mutex.new
  
  texts.each_with_index do |text, index|
    threads << Thread.new do
      begin
        response = client.embeddings.create(
          input: text,
          model: 'embedding-3'
        )
        
        embedding_vector = response.first_embedding
        dimensions = embedding_vector.length
        
        mutex.synchronize do
          embeddings[index] = {
            text: text,
            dimensions: dimensions,
            embedding: embedding_vector,
            similarity: nil
          }
        end
      rescue => e
        mutex.synchronize do
          embeddings[index] = {
            text: text,
            error: e.message,
            dimensions: 0,
            embedding: nil,
            similarity: nil
          }
        end
      end
    end
  end
  
  threads.each(&:join)
  
  # Calculate similarities between embeddings
  if embeddings.length > 1 && embeddings.all? { |e| e[:embedding] }
    embeddings.each_with_index do |embedding1, i|
      embeddings.each_with_index do |embedding2, j|
        next if i == j
        
        if embedding1[:embedding] && embedding2[:embedding]
          similarity = cosine_similarity(embedding1[:embedding], embedding2[:embedding])
          embeddings[i][:similarity] ||= {}
          embeddings[i][:similarity][j] = similarity
        end
      end
    end
  end
  
  embeddings
end

def cosine_similarity(vec1, vec2)
  dot_product = vec1.zip(vec2).sum { |a, b| a * b }
  magnitude1 = Math.sqrt(vec1.sum { |x| x ** 2 })
  magnitude2 = Math.sqrt(vec2.sum { |x| x ** 2 })
  
  return 0.0 if magnitude1 == 0 || magnitude2 == 0
  dot_product / (magnitude1 * magnitude2)
end

embedding_texts = [
  "Ruby programming language",
  "Python programming language", 
  "JavaScript programming language"
]

embedding_results = concurrent_embeddings(embedding_texts)

puts "Embedding Results:"
embedding_results.each_with_index do |result, index|
  if result[:error]
    puts "✗ Embedding #{index + 1}: Error - #{result[:error]}"
  else
    puts "✓ Embedding #{index + 1}: #{result[:text][0..30]}..."
    puts "  Dimensions: #{result[:dimensions]}"
    
    if result[:similarity]
      puts "  Similarities:"
      result[:similarity].each do |idx, similarity|
        next if idx == index
        puts "    - To text #{idx + 1}: #{similarity.round(4)}"
      end
    end
  end
end

# Example 5: Rate Limiting with Thread Pool
puts "\n5. Rate Limiting with Thread Pool..."
puts "-" * 30

require 'timeout'

class RateLimitedClient
  def initialize(client, max_concurrent: 3)
    @client = client
    @max_concurrent = max_concurrent
    @current_requests = 0
    @request_mutex = Mutex.new
  end
  
  def chat_completion(prompt)
    @request_mutex.synchronize do
      while @current_requests >= @max_concurrent
        puts "Rate limit reached, waiting..."
        sleep(1)
      end
      @current_requests += 1
    end
    
    begin
      response = @client.chat.completions.create(
        model: 'glm-5',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 50
      )
      return response
    ensure
      @request_mutex.synchronize { @current_requests -= 1 }
    end
  end
end

rate_limited_client = RateLimitedClient.new(client, max_concurrent: 2)

rate_limit_prompts = [
  "What is concurrency?",
  "Explain thread safety",
  "How does rate limiting work?",
  "What are mutexes?",
  "Define parallel processing"
]

rate_limit_threads = rate_limit_prompts.map.with_index do |prompt, index|
  Thread.new do
    begin
      Timeout::timeout(10) do
        response = rate_limited_client.chat_completion(prompt)
        puts "✓ Limited #{index + 1}: #{response.content[0..60]}..."
      end
    rescue Timeout::Error
      puts "⏰ Limited #{index + 1}: Timeout"
    rescue => e
      puts "✗ Limited #{index + 1}: Error - #{e.message}"
    end
  end
end

rate_limit_threads.each(&:join)

puts "\nAsync Programming Examples Complete!"
puts "\nKey patterns demonstrated:"
puts "1. Thread-based concurrent request processing"
puts "2. Fiber-based lazy evaluation with Enumerators"
puts "3. Async stream processing with background threads"
puts "4. Concurrent embeddings with similarity calculation"
puts "5. Rate limiting with controlled concurrency"
puts "\nRuby Concurrency Tips:"
puts "- Use Mutex for shared resource synchronization"
puts "- Consider Thread pool for managing concurrent operations"
puts "- Handle exceptions in individual threads"
puts "- Use Timeout for preventing hanging operations"
puts "- Beware of Ruby GIL for CPU-bound tasks"