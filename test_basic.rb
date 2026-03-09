#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple test to verify SDK loads and basic functionality works
# This tests core functionality without full RSpec dependencies

puts "Testing Z.ai Ruby SDK with Ruby #{RUBY_VERSION}"
puts "=" * 70

tests_passed = 0
tests_failed = 0

def test(name)
  print "Testing #{name}... "
  begin
    result = yield
    puts "✓ PASS"
    return true
  rescue => e
    puts "✗ FAIL: #{e.message}"
    puts "  #{e.backtrace[0]}" if ENV['DEBUG']
    return false
  end
end

# Test 1: Load SDK
if test("SDK loads") do
  require_relative 'lib/z/ai'
  true
end
  tests_passed += 1
else
  tests_failed += 1
  puts "\nCannot continue - SDK failed to load"
  exit 1
end

# Test 2: Version constant
if test("Version constant exists") do
  raise "No VERSION" unless defined?(Z::AI::VERSION)
  raise "Empty VERSION" if Z::AI::VERSION.empty?
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Test 3: Configuration
if test("Configuration works") do
  config = Z::AI::Configuration.new
  config.api_key = 'test_key.12345'
  config.validate!
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Test 4: Client initialization
if test("Client initializes") do
  client = Z::AI::Client.new(api_key: 'test_key.12345')
  raise "No client" unless client
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Test 5: API resources exist
if test("Chat API resource") do
  client = Z::AI::Client.new(api_key: 'test_key.12345')
  raise "No chat" unless client.respond_to?(:chat)
  chat = client.chat
  raise "Wrong type" unless chat.is_a?(Z::AI::Resources::Chat::Completions)
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

if test("Embeddings API resource") do
  client = Z::AI::Client.new(api_key: 'test_key.12345')
  raise "No embeddings" unless client.respond_to?(:embeddings)
  embeddings = client.embeddings
  raise "Wrong type" unless embeddings.is_a?(Z::AI::Resources::Embeddings)
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

if test("Images API resource") do
  client = Z::AI::Client.new(api_key: 'test_key.12345')
  raise "No images" unless client.respond_to?(:images)
  images = client.images
  raise "Wrong type" unless images.is_a?(Z::AI::Resources::Images)
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

if test("Files API resource") do
  client = Z::AI::Client.new(api_key: 'test_key.12345')
  raise "No files" unless client.respond_to?(:files)
  files = client.files
  raise "Wrong type" unless files.is_a?(Z::AI::Resources::Files)
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Test 6: Error classes
if test("Error classes work") do
  error = Z::AI::Error.new(message: 'Test error')
  raise "Wrong message" unless error.message == 'Test error'
  
  api_error = Z::AI::APIAuthenticationError.new(
    message: 'Auth failed',
    http_status: 401
  )
  raise "Wrong status" unless api_error.http_status == 401
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Test 7: JWT Token generation
if test("JWT token generation") do
  token = Z::AI::Auth::JWTToken.generate_token('id.secret')
  raise "Empty token" if token.empty?
  raise "Not JWT format" unless token.split('.').length == 3
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Test 8: JWT caching
if test("JWT token caching") do
  Z::AI::Auth::JWTToken.clear_cache
  
  token1 = Z::AI::Auth::JWTToken.generate_token('test_id.test_secret')
  token2 = Z::AI::Auth::JWTToken.generate_token('test_id.test_secret')
  
  raise "Tokens not cached" unless token1 == token2
  
  stats = Z::AI::Auth::JWTToken.cache_stats
  raise "Cache stats wrong" unless stats[:size] >= 1
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Test 9: Configuration validation
if test("Configuration validation") do
  config = Z::AI::Configuration.new
  
  # Should fail without API key
  begin
    config.validate!
    raise "Should have failed"
  rescue Z::AI::ConfigurationError
    # Expected
  end
  
  # Should succeed with API key
  config.api_key = 'valid_key'
  config.validate!
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Test 10: Global configuration
if test("Global configuration") do
  Z::AI.configure do |config|
    config.api_key = 'global_test_key'
    config.timeout = 60
  end
  
  raise "Config not set" unless Z::AI.configuration.api_key == 'global_test_key'
  raise "Timeout wrong" unless Z::AI.configuration.timeout == 60
  
  Z::AI.reset!
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Test 11: Model instantiation
if test("Chat models instantiate") do
  message = Z::AI::Models::Chat::Message.new(
    role: 'user',
    content: 'Hello'
  )
  raise "Wrong role" unless message.role == 'user'
  raise "Wrong content" unless message.content == 'Hello'
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Test 12: Client with custom options
if test("Client with custom options") do
  client = Z::AI::Client.new(
    api_key: 'test_key',
    timeout: 45,
    max_retries: 5
  )
  
  raise "Timeout wrong" unless client.config.timeout == 45
  raise "Retries wrong" unless client.config.max_retries == 5
  true
end
  tests_passed += 1
else
  tests_failed += 1
end

# Summary
puts "\n" + "=" * 70
puts "Test Summary"
puts "=" * 70
puts "Passed: #{tests_passed}"
puts "Failed: #{tests_failed}"
puts "Total:  #{tests_passed + tests_failed}"

if tests_failed == 0
  puts "\n✅ All basic tests passed!"
  puts "\nThe SDK core functionality works correctly with Ruby #{RUBY_VERSION}"
  exit 0
else
  puts "\n❌ Some tests failed"
  exit 1
end
