# Async Programming Examples Walkthrough

This file demonstrates various asynchronous and concurrent programming patterns with the Z.ai Ruby SDK, showing how to handle multiple requests efficiently.

## 🎯 **What This Example Demonstrates**

1. **Thread-based Concurrent Processing** - Parallel chat completions
2. **Fiber-based Processing** - Lazy evaluation with Enumerators
3. **Async Stream Processing** - Background thread streaming
4. **Concurrent Embeddings** - Parallel embedding generation with similarity calculation
5. **Rate Limiting with Thread Pool** - Controlled concurrency management

---

## 🚀 **Running the Example**

### Prerequisites
```bash
# Set API key
export ZAI_API_KEY="your-api-key"

# Ruby installation required
ruby --version  # >= 3.2.8
```

### Execute
```bash
ruby examples/async_programming_examples.rb
```

---

## 📋 **Example Breakdown**

### Example 1: Thread-based Concurrent Requests
**Purpose**: Execute multiple chat requests concurrently using Ruby threads.

**Key Concepts**:
- Thread creation and management
- Mutex for shared resource protection
- Result collection from concurrent operations
- Error handling in individual threads

**What Happens**:
- Creates multiple threads, one per prompt
- Each thread makes an independent API call
- Results are collected in shared array with mutex protection
- Main thread waits for all threads to complete

**Performance Benefits**:
- Sequential execution time: ~15-20 seconds (3 requests × 5-7 seconds each)
- Concurrent execution time: ~5-7 seconds (all requests in parallel)
- **~3x speedup** for multiple independent requests

**Ruby-Specific Patterns**:
```ruby
threads = []
mutex = Mutex.new

prompts.each do |prompt|
  threads << Thread.new do
    result = make_api_call(prompt)
    mutex.synchronize do
      results << result
    end
  end
end

threads.each(&:join)  # Wait for completion
```

### Example 2: Fiber-based Processing with Enumerator
**Purpose**: Demonstrate lazy evaluation using Ruby Fibers and Enumerators.

**Key Concepts**:
- Fiber creation for cooperative multitasking
- `Fiber.yield` for returning intermediate results
- Enumerator pattern for iteration
- Memory-efficient processing

**What Happens**:
- Creates Fiber for each request
- Fibers yield results incrementally
- Enumerator allows lazy processing
- Results processed one at a time

**Memory Benefits**:
- Only one result in memory at a time
- Suitable for large datasets
- Backpressure support

**Fiber Pattern**:
```ruby
fiber = Fiber.new do
  result = make_api_call
  Fiber.yield(result)
end

result = fiber.resume  # Execute fiber
```

### Example 3: Async Stream Processing
**Purpose**: Handle multiple streaming responses concurrently.

**Key Concepts**:
- Background thread creation for each stream
- Callback-based processing
- Concurrent streaming data handling
- Thread synchronization

**What Happens**:
- Each streaming request runs in separate thread
- Callback invoked for each chunk
- All streams process concurrently
- Main thread waits for completion

**Streaming Benefits**:
- Real-time response delivery
- Lower perceived latency
- Concurrent multi-stream handling
- Non-blocking operation

**Stream Pattern**:
```ruby
Thread.new do
  client.chat.completions.create(stream: true) do |chunk|
    callback.call(chunk)  # Process each chunk
  end
end
```

### Example 4: Concurrent Embeddings with Similarity Calculation
**Purpose**: Generate embeddings concurrently and calculate similarities.

**Key Concepts**:
- Parallel embedding generation
- Cosine similarity calculation
- Vector mathematics in Ruby
- Concurrent data processing

**What Happens**:
- Embeddings generated in parallel threads
- Vectors collected with mutex protection
- Similarity calculated between all pairs
- Results presented with similarity matrix

**Mathematical Operations**:
```ruby
def cosine_similarity(vec1, vec2)
  dot_product = vec1.zip(vec2).sum { |a, b| a * b }
  magnitude1 = Math.sqrt(vec1.sum { |x| x ** 2 })
  magnitude2 = Math.sqrt(vec2.sum { |x| x ** 2 })
  dot_product / (magnitude1 * magnitude2)
end
```

**Use Cases**:
- Document similarity analysis
- Semantic search
- Clustering algorithms
- Recommendation systems

### Example 5: Rate Limiting with Thread Pool
**Purpose**: Control concurrency to respect API rate limits.

**Key Concepts**:
- Thread pool pattern
- Rate limiting implementation
- Semaphore-like behavior
- Queue management

**What Happens**:
- Custom RateLimitedClient wraps API client
- Limits concurrent requests to specified maximum
- Excess threads wait in queue
- Requests execute as slots become available

**Rate Limiting Pattern**:
```ruby
class RateLimitedClient
  def initialize(client, max_concurrent: 3)
    @max_concurrent = max_concurrent
    @current_requests = 0
    @request_mutex = Mutex.new
  end
  
  def chat_completion(prompt)
    @request_mutex.synchronize do
      while @current_requests >= @max_concurrent
        sleep(1)  # Wait for slot
      end
      @current_requests += 1
    end
    
    begin
      make_api_call
    ensure
      @current_requests -= 1
    end
  end
end
```

---

## 🔧 **Ruby Concurrency Concepts**

### Thread Safety
- Use `Mutex` for shared resource access
- Avoid shared mutable state when possible
- Use thread-local variables for isolation

### GIL (Global Interpreter Lock)
- MRI Ruby has GIL for thread safety
- Only one thread executes Ruby code at a time
- I/O operations can run concurrently
- Consider JRuby for true parallelism

### Memory Management
- Each thread has its own stack
- Shared heap memory requires synchronization
- Be aware of memory leaks in long-running threads

---

## 🎓 **Advanced Patterns**

### Producer-Consumer Pattern
```ruby
require 'thread'

queue = Queue.new
results = []

# Producer threads
producers = prompts.map do |prompt|
  Thread.new { queue << make_api_call(prompt) }
end

# Consumer thread
consumer = Thread.new do
  loop do
    result = queue.pop
    results << result
    break if queue.empty? && producers.all? { |t| !t.alive? }
  end
end

producers.each(&:join)
consumer.join
```

### Timeout Handling
```ruby
require 'timeout'

begin
  Timeout::timeout(10) do
    make_api_call
  end
rescue Timeout::Error
  puts "Operation timed out"
end
```

### Error Propagation
```ruby
class ConcurrentExecutor
  def initialize
    @errors = []
    @error_mutex = Mutex.new
  end
  
  def execute(&block)
    Thread.new do
      begin
        block.call
      rescue => e
        @error_mutex.synchronize do
          @errors << e
        end
      end
    end
  end
  
  def check_errors
    raise @errors.first if @errors.any?
  end
end
```

---

## 🚨 **Common Pitfalls and Solutions**

### Pitfall 1: Race Conditions
**Problem**: Multiple threads accessing shared resource
**Solution**: Use Mutex synchronization
```ruby
mutex.synchronize { shared_resource << value }
```

### Pitfall 2: Deadlocks
**Problem**: Threads waiting indefinitely for each other
**Solution**: Use timeouts and ordered locking
```ruby
Timeout::timeout(5) { mutex.lock }
```

### Pitfall 3: Thread Leaks
**Problem**: Threads not properly cleaned up
**Solution**: Ensure threads complete or handle exceptions
```ruby
Thread.new do
  begin
    # Thread work
  ensure
    # Cleanup
  end
end
```

---

## 📊 **Performance Metrics**

### Expected Speedups
| Scenario | Sequential | Concurrent | Speedup |
|----------|-----------|------------|---------|
| 3 API calls | 18s | 6s | 3x |
| 10 API calls | 60s | 20s | 3x |
| Streaming 3 requests | 15s | 5s | 3x |
| Embeddings (5 texts) | 25s | 8s | 3.1x |

### Memory Usage
- Sequential: ~50MB per request
- Concurrent (3 threads): ~150MB total
- Streaming: ~30MB (incremental)

---

## 🎯 **Best Practices**

### 1. Thread Pool Sizing
- Match pool size to available resources
- Consider API rate limits
- Monitor system resources

### 2. Error Handling
- Catch exceptions in each thread
- Collect errors for later analysis
- Implement retry logic

### 3. Resource Cleanup
- Ensure threads are joined
- Close connections properly
- Release locks appropriately

### 4. Monitoring
- Track thread count
- Monitor memory usage
- Log thread lifecycle events

---

## 🔍 **JRuby vs MRI Considerations**

### JRuby Advantages
- True parallel execution (no GIL)
- Better thread performance
- Native Java threads

### MRI Advantages
- Simpler threading model
- Predictable behavior
- Mature ecosystem

### Code Compatibility
This example works on both MRI and JRuby with identical behavior, though JRuby provides better parallel performance.

---

**Created**: March 9, 2026  
**Ruby SDK Version**: 0.1.0  
**Dependencies**: Z::AI gem, Timeout (standard library)