# Error Handling Examples Walkthrough

This file demonstrates comprehensive error handling strategies for the Z.ai Ruby SDK, showing how to build robust applications that gracefully handle various failure scenarios.

## 🎯 **What This Example Demonstrates**

1. **Specific Error Type Handling** - Catching different API errors appropriately
2. **Authentication Error Management** - Handling invalid API keys and auth failures  
3. **Rate Limit Handling** - Dealing with API rate limiting
4. **Retry Logic Implementation** - Automatic retry with exponential backoff
5. **Fallback Strategies** - Graceful degradation when primary methods fail
6. **Batch Processing with Error Recovery** - Handling multiple requests with individual error tracking
7. **Comprehensive Logging** - Debug-level error logging and monitoring

---

## 🚀 **Running the Example**

### Prerequisites
```bash
# Set your API key as environment variable
export ZAI_API_KEY="your-actual-api-key"

# Or modify the example to include your key directly
```

### Execute
```bash
ruby examples/error_handling_examples.rb
```

---

## 📋 **Example Breakdown**

### Example 1: Invalid Request Error
**Purpose**: Demonstrates handling of validation errors when invalid data is sent to the API.

**Key Concepts**:
- `Z::AI::ValidationError` for input validation failures
- Error context preservation (code, HTTP status)
- Graceful error message display

**What Happens**:
- Attempts to create a chat completion with empty messages array
- SDK validates this and raises `ValidationError`
- Error is caught and displayed with full context

**Ruby-Specific Patterns**:
```ruby
rescue Z::AI::ValidationError => e
  puts "✓ Caught ValidationError: #{e.message}"
  puts "  Error details: #{e.code || 'No code'}"
  puts "  HTTP Status: #{e.http_status || 'No HTTP status'}"
end
```

### Example 2: Authentication Error
**Purpose**: Shows how to handle API authentication failures.

**Key Concepts**:
- `Z::AI::APIAuthenticationError` for auth failures
- Separating client instances for different auth contexts
- Early error detection

**What Happens**:
- Creates client with invalid API key
- Attempts API call
- Authentication fails and is caught appropriately

**Best Practices Demonstrated**:
- Separate client instances for different auth contexts
- Immediate failure detection for auth issues
- User-friendly error messages

### Example 3: Rate Limit Handling
**Purpose**: Demonstrates handling of API rate limiting scenarios.

**Key Concepts**:
- `Z::AI::APIRateLimitError` for rate limiting
- Iterative request pattern with error detection
- Graceful interruption when limits are hit

**What Happens**:
- Makes multiple rapid requests
- Detects rate limiting after threshold
- Stops processing gracefully without crashing

**Rate Limiting Strategy**:
```ruby
rescue Z::AI::APIRateLimitError => e
  puts "  Rate limited - #{e.message}"
  break  # Stop processing when rate limited
end
```

### Example 4: Server Error Resilience
**Purpose**: Shows retry logic for handling temporary server issues.

**Key Concepts**:
- Retry configuration (`max_retries`, `retry_delay`)
- `Z::AI::APITimeoutError` for timeout scenarios
- Automatic retry with configurable limits

**What Happens**:
- Configures client with retry settings
- Makes request that may face temporary issues
- SDK automatically retries on failures

**Retry Configuration**:
```ruby
client_with_retries = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'],
  max_retries: 3,        # Maximum retry attempts
  retry_delay: 2           # Delay between retries
)
```

### Example 5: Error Recovery with Fallback
**Purpose**: Demonstrates fallback strategies when primary approaches fail.

**Key Concepts**:
- Custom retry function with exponential backoff
- Model fallback (complex → simple)
- Graceful degradation strategies

**What Happens**:
- Implements custom retry logic with exponential backoff
- Falls back to simpler model when rate limited
- Maintains functionality even under constraints

**Fallback Pattern**:
```ruby
def chat_with_fallback(message, max_retries = 2)
  # Try primary approach with retries
  # On failure, fallback to simpler model
  return Client.chat.completions.create(model: 'glm-4', ...)
end
```

### Example 6: Batch Processing with Error Recovery
**Purpose**: Shows how to handle multiple requests with individual error tracking.

**Key Concepts**:
- Array-based request processing
- Separate success and error tracking
- Statistics calculation for monitoring

**What Happens**:
- Processes multiple requests sequentially
- Tracks individual successes and failures
- Calculates success rate for monitoring

**Batch Error Handling**:
```ruby
requests.each_with_index do |request, index|
  begin
    # Process individual request
    results[index] = response.content
  rescue Z::AI::APIRateLimitError => e
    errors[index] = "Rate limited: #{e.message}"
    sleep(1)  # Wait before next request
  end
end
```

### Example 7: Comprehensive Error Logging
**Purpose**: Demonstrates proper logging setup for debugging and monitoring.

**Key Concepts**:
- Logger configuration
- Debug-level logging for detailed information
- Error context preservation

**What Happens**:
- Configures client with custom logger
- Enables debug logging for detailed request/response info
- Errors are logged with full context for debugging

**Logging Configuration**:
```ruby
client_with_logging = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'],
  logger: Logger.new($stdout),
  log_level: :debug
)
```

---

## 🔧 **Error Handling Best Practices Demonstrated**

### 1. **Specific Exception Handling**
- Catch specific error types (`ValidationError`, `APIAuthenticationError`, etc.)
- Avoid generic `rescue => e` unless absolutely necessary
- Provide different handling strategies for different error types

### 2. **Context Preservation**
- Error objects contain full context (message, code, HTTP status)
- Preserve original error information in logs
- Provide actionable error messages to users

### 3. **Graceful Degradation**
- Implement fallback strategies when primary methods fail
- Maintain functionality even with reduced capabilities
- Inform users about degraded state

### 4. **Retry with Exponential Backoff**
- Use exponential delays for retry attempts
- Configure maximum retry limits to prevent infinite loops
- Implement jitter to avoid thundering herd problems

### 5. **Monitoring and Logging**
- Log errors at appropriate levels
- Include request context in error logs
- Provide statistics for monitoring (success rates, error types)

### 6. **User Communication**
- Clear error messages that explain what happened
- Provide actionable advice for resolving issues
- Graceful handling of expected conditions (rate limits)

---

## 🎓 **Advanced Error Handling Patterns**

### Circuit Breaker Pattern
```ruby
class CircuitBreaker
  def initialize(failure_threshold: 5, timeout: 60)
    @failure_count = 0
    @failure_threshold = failure_threshold
    @timeout = timeout
    @last_failure_time = nil
    @state = :closed  # :closed, :open, :half_open
  end
  
  def call(&block)
    return :open if @state == :open
    
    begin
      result = yield
      reset if @state == :half_open
      result
    rescue => e
      record_failure
      raise
    end
  end
  
  private
  
  def record_failure
    @failure_count += 1
    @last_failure_time = Time.now
    
    if @failure_count >= @failure_threshold
      @state = :open
      # Wait before trying again
    elsif @failure_count >= @failure_threshold / 2
      @state = :half_open
    end
  end
  
  def reset
    @failure_count = 0
    @state = :closed
  end
end
```

### Error Aggregation for Monitoring
```ruby
class ErrorTracker
  def initialize
    @errors = {}
    @requests = 0
  end
  
  def record_request
    @requests += 1
  end
  
  def record_error(error_type, error_details = nil)
    @errors[error_type] ||= { count: 0, details: [] }
    @errors[error_type][:count] += 1
    @errors[error_type][:details] << error_details if error_details
  end
  
  def error_report
    total_errors = @errors.values.sum { |e| e[:count] }
    {
      total_requests: @requests,
      total_errors: total_errors,
      error_rate: (total_errors.to_f / @requests * 100).round(2),
      error_breakdown: @errors
    }
  end
end
```

---

## 🎯 **Production Deployment Considerations**

### 1. **Error Monitoring Integration**
- Send error data to monitoring services (Sentry, Bugsnag)
- Implement error alerting for critical failures
- Track error trends over time

### 2. **Graceful Shutdown**
- Handle `Interrupt` signals for clean shutdown
- Save in-flight operations state
- Log shutdown reasons

### 3. **Configuration Management**
- Environment-specific error handling (development vs production)
- Feature flags for different error handling strategies
- Dynamic retry configuration

### 4. **Health Check Implementation**
- Regular health checks to detect issues early
- Dependency health monitoring
- Automatic recovery mechanisms

---

## 🔍 **Debugging Tips**

### 1. **Enable Debug Logging**
```ruby
client = Z::AI::Client.new(
  api_key: ENV['ZAI_API_KEY'],
  logger: Logger.new($stdout),
  log_level: :debug
)
```

### 2. **Inspect Error Objects**
```ruby
rescue Z::AI::APIStatusError => e
  puts "Error class: #{e.class}"
  puts "Error message: #{e.message}"
  puts "Error code: #{e.code}"
  puts "HTTP status: #{e.http_status}"
  puts "Response body: #{e.http_body}"
end
```

### 3. **Use Network Tools**
- `curl` to test API endpoints directly
- Wireshark/tcpdump for network-level debugging
- Browser developer tools for request inspection

---

**Created**: March 9, 2026  
**Ruby SDK Version**: 0.1.0  
**Dependencies**: Z::AI gem, Logger (standard library)