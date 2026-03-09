# Streaming Chat Examples Walkthrough

This guide demonstrates advanced streaming chat patterns with the Z.ai Ruby SDK.

## What You'll Learn

1. Real-time response streaming with live display
2. Content accumulation and metrics collection
3. Progress indicators during streaming
4. Error recovery and retry strategies
5. Word-by-word streaming for better UX
6. File output for persistent storage
7. Parallel streaming request handling
8. JSON extraction from streaming responses
9. Typing effect for enhanced user experience
10. Comprehensive streaming analytics

## Running the Examples

```bash
export ZAI_API_KEY="your-api-key"
ruby examples/streaming_chat_examples.rb
```

## Key Patterns

### Pattern 1: Real-time Display
Stream responses character-by-character for immediate feedback.

### Pattern 2: Progress Tracking
Show visual progress during long-running streams.

### Pattern 3: Error Handling
Implement retry logic for interrupted streams.

### Pattern 4: Parallel Streaming
Handle multiple streaming requests concurrently.

### Pattern 5: Analytics
Collect detailed metrics during streaming.

## Performance Tips

- Use buffers to reduce display overhead
- Implement backpressure for slow consumers
- Handle network interruptions gracefully
- Monitor chunk sizes and timing

## Common Use Cases

- Chatbots with real-time responses
- Long-form content generation
- Interactive AI assistants
- Educational applications
- Content streaming services
