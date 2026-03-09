# frozen_string_literal: true

require_relative '../lib/z/ai'
require 'json'
require 'fileutils'

puts "Batch Processing and Automation Examples"
puts "=" * 50

client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'] || 'your-api-key-here'
)

# Example 1: Batch Text Processing
puts "\n1. Batch Text Processing"
puts "-" * 30

texts_to_process = [
  "The quick brown fox jumps over the lazy dog.",
  "Ruby is a dynamic, open source programming language.",
  "Machine learning is transforming industries worldwide.",
  "Clean code is essential for maintainable software.",
  "APIs enable seamless integration between services."
]

batch_summaries = []

texts_to_process.each_with_index do |text, index|
  puts "Processing text #{index + 1}/#{texts_to_process.length}..."
  
  response = client.chat.completions.create(
    model: 'glm-5',
    messages: [
      { 
        role: 'system', 
        content: 'Summarize the following text in one concise sentence.' 
      },
      { role: 'user', content: text }
    ],
    max_tokens: 50
  )
  
  batch_summaries << {
    original: text,
    summary: response.content,
    tokens: response.usage.total_tokens
  }
end

puts "\nBatch Processing Results:"
batch_summaries.each_with_index do |item, index|
  puts "#{index + 1}. Original: #{item[:original][0..40]}..."
  puts "   Summary: #{item[:summary]}"
  puts "   Tokens: #{item[:tokens]}"
  puts
end

# Example 2: Batch Embedding Generation
puts "\n2. Batch Embedding Generation"
puts "-" * 30

def generate_batch_embeddings(texts)
  embeddings = []
  
  texts.each_with_index do |text, index|
    puts "Generating embedding #{index + 1}/#{texts.length}..."
    
    response = client.embeddings.create(
      input: text,
      model: 'embedding-3'
    )
    
    embeddings << {
      text: text,
      embedding: response.first_embedding,
      dimensions: response.first_embedding.length
    }
  end
  
  embeddings
end

embedding_texts = [
  "Artificial intelligence",
  "Natural language processing",
  "Computer vision",
  "Robotics and automation"
]

embeddings = generate_batch_embeddings(embedding_texts)

puts "\nEmbedding Results:"
embeddings.each_with_index do |item, index|
  puts "#{index + 1}. Text: #{item[:text]}"
  puts "   Dimensions: #{item[:dimensions]}"
  puts "   First 5 values: #{item[:embedding][0..4]}"
  puts
end

# Example 3: Batch File Processing
puts "\n3. Batch File Processing"
puts "-" * 30

# Create temporary files for demonstration
FileUtils.mkdir_p('tmp/batch_files')

sample_files = {
  'document1.txt' => "Ruby is known for its elegant syntax and developer happiness.",
  'document2.txt' => "Python excels in data science and machine learning.",
  'document3.txt' => "JavaScript powers interactive web applications."
}

sample_files.each do |filename, content|
  File.write("tmp/batch_files/#{filename}", content)
end

# Process files in batch
def process_files_batch(directory)
  results = []
  
  Dir.glob("#{directory}/*.txt").sort.each_with_index do |filepath, index|
    puts "Processing file #{index + 1}: #{File.basename(filepath)}"
    
    content = File.read(filepath)
    
    response = client.chat.completions.create(
      model: 'glm-5',
      messages: [
        { 
          role: 'user', 
          content: "Analyze and extract key topics from this text: #{content}" 
        }
      ],
      max_tokens: 100
    )
    
    results << {
      filename: File.basename(filepath),
      content: content,
      analysis: response.content,
      size: File.size(filepath)
    }
  end
  
  results
end

file_results = process_files_batch('tmp/batch_files')

puts "\nFile Processing Results:"
file_results.each do |result|
  puts "File: #{result[:filename]} (#{result[:size]} bytes)"
  puts "Analysis: #{result[:analysis]}"
  puts
end

# Example 4: Batch API Calls with Progress Tracking
puts "\n4. Batch Processing with Progress Tracking"
puts "-" * 30

class BatchProcessor
  def initialize(total_items)
    @total_items = total_items
    @processed = 0
    @failed = 0
    @start_time = Time.now
  end
  
  def process_item(item, &block)
    begin
      result = yield(item)
      @processed += 1
      print_progress
      result
    rescue => e
      @failed += 1
      print_progress
      { error: e.message }
    end
  end
  
  def print_progress
    percentage = ((@processed + @failed).to_f / @total_items * 100).round(1)
    elapsed = Time.now - @start_time
    rate = (@processed + @failed) / elapsed
    
    print "\rProgress: #{@processed + @failed}/#{@total_items} (#{percentage}%) | "
    print "Success: #{@processed} | Failed: #{@failed} | "
    print "Rate: #{rate.round(2)} items/s"
    $stdout.flush
  end
  
  def summary
    elapsed = Time.now - @start_time
    puts "\n\nBatch Summary:"
    puts "  Total items: #{@total_items}"
    puts "  Processed: #{@processed}"
    puts "  Failed: #{@failed}"
    puts "  Success rate: #{(@processed.to_f / @total_items * 100).round(1)}%"
    puts "  Total time: #{elapsed.round(2)}s"
    puts "  Average rate: #{(@total_items / elapsed).round(2)} items/s"
  end
end

batch_items = [
  "Analyze machine learning trends",
  "Review web development practices",
  "Summarize cloud computing benefits",
  "Evaluate DevOps methodologies",
  "Explain microservices architecture"
]

processor = BatchProcessor.new(batch_items.length)

results = batch_items.map do |item|
  processor.process_item(item) do |prompt|
    client.chat.completions.create(
      model: 'glm-5',
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 80
    ).content
  end
end

processor.summary

# Example 5: Parallel Batch Processing
puts "\n5. Parallel Batch Processing"
puts "-" * 30

require 'thread'

def parallel_batch_process(items, concurrency: 3)
  results = []
  mutex = Mutex.new
  queue = Queue.new
  
  # Enqueue items
  items.each { |item| queue << item }
  items.length.times { queue << :done }  # Sentinel values
  
  # Worker threads
  workers = concurrency.times.map do
    Thread.new do
      while (item = queue.pop) != :done
        begin
          response = client.chat.completions.create(
            model: 'glm-5',
            messages: [{ role: 'user', content: item }],
            max_tokens: 60
          )
          
          mutex.synchronize do
            results << { item: item, response: response.content }
          end
        rescue => e
          mutex.synchronize do
            results << { item: item, error: e.message }
          end
        end
      end
    end
  end
  
  workers.each(&:join)
  results
end

parallel_items = [
  "Explain REST APIs",
  "Define GraphQL",
  "Compare SQL vs NoSQL",
  "Describe Docker containers",
  "Outline CI/CD pipeline",
  "Review agile methodology"
]

puts "Processing #{parallel_items.length} items with 3 concurrent workers..."
start = Time.now
parallel_results = parallel_batch_process(parallel_items, concurrency: 3)
elapsed = Time.now - start

puts "\nParallel Processing Results (#{elapsed.round(2)}s):"
parallel_results.each_with_index do |result, index|
  if result[:error]
    puts "#{index + 1}. ✗ #{result[:item][0..30]}: Error - #{result[:error]}"
  else
    puts "#{index + 1}. ✓ #{result[:item][0..30]}: #{result[:response][0..40]}..."
  end
end

# Example 6: Batch Processing with Retry Logic
puts "\n6. Batch Processing with Retry Logic"
puts "-" * 30

def batch_with_retry(items, max_retries: 3)
  results = []
  
  items.each_with_index do |item, index|
    retries = 0
    success = false
    
    until success || retries >= max_retries
      begin
        puts "Processing item #{index + 1} (attempt #{retries + 1})..."
        
        response = client.chat.completions.create(
          model: 'glm-5',
          messages: [{ role: 'user', content: item }],
          max_tokens: 50
        )
        
        results << { item: item, response: response.content }
        success = true
        puts "  ✓ Success"
        
      rescue => e
        retries += 1
        puts "  ✗ Attempt #{retries} failed: #{e.message}"
        
        if retries < max_retries
          sleep(2 ** retries)  # Exponential backoff
          puts "  Retrying..."
        else
          results << { item: item, error: e.message, retries: retries }
          puts "  ✗ Max retries reached"
        end
      end
    end
  end
  
  results
end

retry_items = [
  "Explain recursion",
  "Define polymorphism",
  "Describe inheritance"
]

retry_results = batch_with_retry(retry_items, max_retries: 2)

puts "\nRetry Results:"
retry_results.each do |result|
  if result[:error]
    puts "✗ #{result[:item]}: Failed after #{result[:retries]} attempts"
  else
    puts "✓ #{result[:item]}: #{result[:response][0..50]}..."
  end
end

# Example 7: Batch Results Export
puts "\n7. Batch Results Export"
puts "-" * 30

export_data = [
  { id: 1, query: "What is AI?", answer: "Artificial intelligence is..." },
  { id: 2, query: "Explain ML", answer: "Machine learning involves..." },
  { id: 3, query: "Define DL", answer: "Deep learning uses..." }
]

# Export to JSON
json_file = 'tmp/batch_results.json'
File.write(json_file, JSON.pretty_generate(export_data))
puts "Exported to JSON: #{json_file}"

# Export to CSV
csv_file = 'tmp/batch_results.csv'
CSV.open(csv_file, 'w') do |csv|
  csv << ['ID', 'Query', 'Answer']
  export_data.each { |row| csv << row.values }
end
puts "Exported to CSV: #{csv_file}"

# Export to Markdown
md_file = 'tmp/batch_results.md'
File.write(md_file, "# Batch Processing Results\n\n")
File.open(md_file, 'a') do |f|
  export_data.each do |row|
    f.puts "## Item #{row[:id]}\n"
    f.puts "**Query:** #{row[:query]}\n\n"
    f.puts "**Answer:** #{row[:answer]}\n\n"
  end
end
puts "Exported to Markdown: #{md_file}"

# Example 8: Batch Validation
puts "\n8. Batch Validation and Filtering"
puts "-" * 30

validation_items = [
  "Valid request about programming",
  "",  # Empty - should be filtered
  "Another valid request",
  "x" * 10000,  # Too long - should be filtered
  "Short valid text"
]

def validate_batch(items)
  valid_items = []
  invalid_items = []
  
  items.each_with_index do |item, index|
    errors = []
    
    # Validation rules
    errors << "Empty" if item.nil? || item.empty?
    errors << "Too long (#{item.length} chars)" if item.length > 1000
    errors << "No alphanumeric content" unless item.match?(/[a-zA-Z0-9]/)
    
    if errors.empty?
      valid_items << { index: index, content: item }
    else
      invalid_items << { index: index, content: item[0..50], errors: errors }
    end
  end
  
  { valid: valid_items, invalid: invalid_items }
end

validation_result = validate_batch(validation_items)

puts "Validation Results:"
puts "  Valid items: #{validation_result[:valid].length}"
puts "  Invalid items: #{validation_result[:invalid].length}"
puts "\nInvalid items:"
validation_result[:invalid].each do |item|
  puts "  Index #{item[:index]}: #{item[:errors].join(', ')}"
end

# Example 9: Batch Rate Limiting
puts "\n9. Batch Processing with Rate Limiting"
puts "-" * 30

class RateLimiter
  def initialize(requests_per_second: 2)
    @rate = requests_per_second
    @last_request = nil
    @mutex = Mutex.new
  end
  
  def throttle
    @mutex.synchronize do
      if @last_request
        elapsed = Time.now - @last_request
        min_interval = 1.0 / @rate
        sleep(min_interval - elapsed) if elapsed < min_interval
      end
      
      result = yield
      @last_request = Time.now
      result
    end
  end
end

limiter = RateLimiter.new(requests_per_second: 2)

rate_limited_items = [
  "Request 1", "Request 2", "Request 3", "Request 4"
]

puts "Processing #{rate_limited_items.length} items at 2 requests/second..."
start_time = Time.now

rate_limited_results = rate_limited_items.map do |item|
  limiter.throttle do
    puts "  Processing: #{item} at #{Time.now.strftime('%H:%M:%S')}"
    { item: item, processed_at: Time.now }
  end
end

total_time = Time.now - start_time
puts "Completed in #{total_time.round(2)}s"
puts "Average rate: #{(rate_limited_items.length / total_time).round(2)} req/s"

# Example 10: Batch Job Queue System
puts "\n10. Batch Job Queue System"
puts "-" * 30

class BatchJobQueue
  def initialize
    @queue = []
    @completed = []
    @failed = []
  end
  
  def enqueue(item)
    job = {
      id: SecureRandom.uuid,
      item: item,
      status: :pending,
      enqueued_at: Time.now
    }
    @queue << job
    job[:id]
  end
  
  def process_all(&processor)
    while job = @queue.shift
      begin
        puts "Processing job #{job[:id]}..."
        result = yield(job[:item])
        
        job[:status] = :completed
        job[:result] = result
        job[:completed_at] = Time.now
        @completed << job
        
        puts "  ✓ Completed"
      rescue => e
        job[:status] = :failed
        job[:error] = e.message
        job[:failed_at] = Time.now
        @failed << job
        
        puts "  ✗ Failed: #{e.message}"
      end
    end
  end
  
  def status
    {
      pending: @queue.length,
      completed: @completed.length,
      failed: @failed.length,
      total: @queue.length + @completed.length + @failed.length
    }
  end
end

queue = BatchJobQueue.new

# Enqueue jobs
job_ids = [
  "Process data A",
  "Process data B",
  "Process data C"
].map { |item| queue.enqueue(item) }

puts "Enqueued #{job_ids.length} jobs"

# Process all jobs
queue.process_all do |item|
  client.chat.completions.create(
    model: 'glm-5',
    messages: [{ role: 'user', content: "Briefly describe: #{item}" }],
    max_tokens: 30
  ).content
end

puts "\nQueue Status:"
puts JSON.pretty_generate(queue.status)

puts "\nBatch Processing Examples Complete!"
puts "\nKey batch processing patterns demonstrated:"
puts "1. Sequential batch text processing"
puts "2. Batch embedding generation"
puts "3. File batch processing"
puts "4. Progress tracking and reporting"
puts "5. Parallel batch processing"
puts "6. Retry logic for failed items"
puts "7. Results export to multiple formats"
puts "8. Input validation and filtering"
puts "9. Rate limiting for API compliance"
puts "10. Job queue system for complex workflows"