# frozen_string_literal: true

require_relative '../lib/z/ai'

puts "Advanced Streaming Chat Examples"
puts "=" * 50

client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here'
)

# Example 1: Basic Streaming with Real-time Display
puts "\n1. Basic Streaming - Real-time Display"
puts "-" * 30

print "AI: "
client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'Write a short poem about Ruby programming' }
  ],
  stream: true
) do |chunk|
  if chunk.delta_content
    print chunk.delta_content
    $stdout.flush
  end
end
puts "\n"

# Example 2: Streaming with Content Accumulation
puts "\n2. Streaming with Content Accumulation"
puts "-" * 30

accumulated_content = ""
chunk_count = 0

client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'Explain the concept of metaprogramming in Ruby' }
  ],
  stream: true
) do |chunk|
  if chunk.delta_content
    accumulated_content += chunk.delta_content
    chunk_count += 1
  end
end

puts "Total chunks received: #{chunk_count}"
puts "Total content length: #{accumulated_content.length} characters"
puts "Preview: #{accumulated_content[0..150]}..."
puts

# Example 3: Streaming with Progress Indicator
puts "\n3. Streaming with Progress Indicator"
puts "-" * 30

dots = 0
start_time = Time.now

print "Processing: "
client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'Generate a long story about a programmer' }
  ],
  stream: true,
  max_tokens: 500
) do |chunk|
  if chunk.delta_content
    dots += 1
    if dots % 5 == 0
      print "."
      $stdout.flush
    end
  end
end

end_time = Time.now
puts " Done!"
puts "Streaming completed in #{(end_time - start_time).round(2)} seconds"
puts

# Example 4: Streaming with Error Recovery
puts "\n4. Streaming with Error Recovery"
puts "-" * 30

def safe_stream_chat(prompt, max_retries = 3)
  retries = 0
  content_parts = []
  
  begin
    client.chat.completions.create(
      model: 'glm-5',
      messages: [{ role: 'user', content: prompt }],
      stream: true
    ) do |chunk|
      if chunk.delta_content
        content_parts << chunk.delta_content
        yield chunk if block_given?
      end
    end
    
    return content_parts.join
  rescue Z::AI::StreamingError => e
    retries += 1
    if retries <= max_retries
      puts "\nStream interrupted, retrying... (#{retries}/#{max_retries})"
      retry
    else
      puts "\nMax retries reached, returning partial content"
      return content_parts.join
    end
  rescue => e
    puts "\nUnexpected error: #{e.message}"
    return content_parts.join
  end
end

puts "Streaming with error handling: "
result = safe_stream_chat("Explain async programming in detail") do |chunk|
  print chunk.delta_content if chunk.delta_content
end
puts "\n\nFinal result length: #{result.length} characters"

# Example 5: Streaming with Word-by-Word Display
puts "\n5. Word-by-Word Streaming Display"
puts "-" * 30

word_buffer = ""

client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'List 5 programming languages with brief descriptions' }
  ],
  stream: true
) do |chunk|
  if chunk.delta_content
    word_buffer += chunk.delta_content
    
    # Display complete words
    if word_buffer.include?(' ') || word_buffer.include?("\n")
      words = word_buffer.split(/(\s+)/)
      
      # Display all but last incomplete word
      words[0..-2].each do |word|
        print word
        $stdout.flush
        sleep(0.05)  # Slight delay for effect
      end
      
      # Keep last (possibly incomplete) word in buffer
      word_buffer = words.last || ""
    end
  end
end

# Display remaining buffer
print word_buffer
puts "\n"

# Example 6: Streaming to File
puts "\n6. Streaming Response to File"
puts "-" * 30

output_file = 'tmp/streaming_output.txt'
FileUtils.mkdir_p('tmp')

File.open(output_file, 'w') do |file|
  client.chat.completions.create(
    model: 'glm-5',
    messages: [
      { role: 'user', content: 'Write a technical article about Ruby gems' }
    ],
    stream: true,
    max_tokens: 300
  ) do |chunk|
    if chunk.delta_content
      file.write(chunk.delta_content)
      print "."  # Progress indicator
      $stdout.flush
    end
  end
end

puts "\nStream saved to #{output_file}"
puts "File size: #{File.size(output_file)} bytes"
puts "Preview:"
puts File.read(output_file)[0..200] + "..."
puts

# Example 7: Parallel Streaming Requests
puts "\n7. Parallel Streaming Requests"
puts "-" * 30

def stream_in_thread(thread_id, prompt)
  Thread.new do
    content = ""
    chunk_count = 0
    
    begin
      client.chat.completions.create(
        model: 'glm-5',
        messages: [{ role: 'user', content: prompt }],
        stream: true,
        max_tokens: 100
      ) do |chunk|
        if chunk.delta_content
          content += chunk.delta_content
          chunk_count += 1
        end
      end
      
      puts "Thread #{thread_id}: Completed (#{chunk_count} chunks, #{content.length} chars)"
      { id: thread_id, content: content, chunks: chunk_count }
    rescue => e
      puts "Thread #{thread_id}: Error - #{e.message}"
      { id: thread_id, error: e.message }
    end
  end
end

stream_prompts = [
  "What is object-oriented programming?",
  "Explain functional programming",
  "Define procedural programming"
]

threads = stream_prompts.map.with_index do |prompt, index|
  stream_in_thread(index + 1, prompt)
end

results = threads.map(&:join).map(&:value)

puts "\nParallel streaming results:"
results.each do |result|
  if result[:error]
    puts "✗ Thread #{result[:id]}: #{result[:error]}"
  else
    puts "✓ Thread #{result[:id]}: #{result[:content][0..50]}..."
  end
end

# Example 8: Streaming with JSON Parsing
puts "\n8. Streaming with JSON Extraction"
puts "-" * 30

json_buffer = ""

client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { 
      role: 'user', 
      content: 'Generate a JSON object with name, age, and hobbies fields for a fictional character' 
    }
  ],
  stream: true
) do |chunk|
  if chunk.delta_content
    json_buffer += chunk.delta_content
    print chunk.delta_content
    $stdout.flush
  end
end

puts "\n\nAttempting to parse JSON..."

begin
  # Extract JSON from response (handles text before/after JSON)
  json_match = json_buffer.match(/\{[^{}]*\}/)
  if json_match
    parsed = JSON.parse(json_match[0])
    puts "✓ Successfully parsed JSON:"
    puts JSON.pretty_generate(parsed)
  else
    puts "✗ No valid JSON found in response"
  end
rescue JSON::ParserError => e
  puts "✗ JSON parsing failed: #{e.message}"
end

# Example 9: Streaming with Typing Effect
puts "\n9. Typing Effect Streaming"
puts "-" * 30

def type_effect_stream(prompt, char_delay: 0.02)
  client.chat.completions.create(
    model: 'glm-5',
    messages: [{ role: 'user', content: prompt }],
    stream: true
  ) do |chunk|
    if chunk.delta_content
      chunk.delta_content.each_char do |char|
        print char
        $stdout.flush
        sleep(char_delay)
      end
    end
  end
  puts
end

puts "AI typing: "
type_effect_stream("Say hello in a friendly way", char_delay: 0.03)

# Example 10: Streaming Analytics
puts "\n10. Streaming Analytics and Metrics"
puts "-" * 30

stream_metrics = {
  start_time: nil,
  end_time: nil,
  chunks: [],
  words: 0,
  characters: 0,
  first_chunk_time: nil,
  avg_chunk_interval: nil
}

stream_metrics[:start_time] = Time.now

client.chat.completions.create(
  model: 'glm-5',
  messages: [
    { role: 'user', content: 'Explain the benefits of Ruby on Rails' }
  ],
  stream: true,
  max_tokens: 200
) do |chunk|
  if chunk.delta_content
    stream_metrics[:first_chunk_time] ||= Time.now
    stream_metrics[:chunks] << {
      time: Time.now,
      content: chunk.delta_content,
      length: chunk.delta_content.length
    }
    stream_metrics[:characters] += chunk.delta_content.length
    stream_metrics[:words] += chunk.delta_content.split.length
  end
end

stream_metrics[:end_time] = Time.now

# Calculate statistics
total_time = stream_metrics[:end_time] - stream_metrics[:start_time]
time_to_first_chunk = stream_metrics[:first_chunk_time] - stream_metrics[:start_time]
chunk_intervals = stream_metrics[:chunks].each_cons(2).map { |a, b| b[:time] - a[:time] }
avg_interval = chunk_intervals.empty? ? 0 : chunk_intervals.sum / chunk_intervals.length

puts "Streaming Metrics:"
puts "  Total time: #{total_time.round(2)}s"
puts "  Time to first chunk: #{time_to_first_chunk.round(2)}s"
puts "  Total chunks: #{stream_metrics[:chunks].length}"
puts "  Average chunk interval: #{avg_interval.round(4)}s"
puts "  Total characters: #{stream_metrics[:characters]}"
puts "  Total words: #{stream_metrics[:words]}"
puts "  Characters per second: #{(stream_metrics[:characters] / total_time).round(1)}"
puts "  Words per second: #{(stream_metrics[:words] / total_time).round(2)}"

puts "\nStreaming Chat Examples Complete!"
puts "\nKey streaming patterns demonstrated:"
puts "1. Real-time display with immediate feedback"
puts "2. Content accumulation and analysis"
puts "3. Progress indicators for user feedback"
puts "4. Error recovery with retry logic"
puts "5. Word-by-word streaming for readability"
puts "6. File output for persistence"
puts "7. Parallel streaming for multiple requests"
puts "8. JSON extraction from streaming responses"
puts "9. Typing effect for better UX"
puts "10. Analytics and performance metrics"