#!/usr/bin/env ruby
# frozen_string_literal: true

# Quick verification script to ensure SDK loads properly
# Run this before running full test suite

puts "Verifying Z.ai Ruby SDK..."
puts "=" * 60

errors = []
success_count = 0

# Test 1: Load the SDK
puts "\n1. Loading SDK..."
begin
  require_relative 'lib/z/ai'
  puts "  ✓ SDK loaded successfully"
  success_count += 1
rescue => e
  puts "  ✗ Failed to load SDK: #{e.message}"
  errors << "Load error: #{e.message}"
end

# Test 2: Verify version
puts "\n2. Checking version..."
begin
  version = Z::AI::VERSION
  puts "  ✓ Version: #{version}"
  success_count += 1
rescue => e
  puts "  ✗ Failed to get version: #{e.message}"
  errors << "Version error: #{e.message}"
end

# Test 3: Verify classes exist
puts "\n3. Verifying classes..."
classes = [
  ['Z::AI::Client', 'Main client'],
  ['Z::AI::Configuration', 'Configuration'],
  ['Z::AI::Error', 'Base error'],
  ['Z::AI::Core::HTTPClient', 'HTTP client'],
  ['Z::AI::Auth::JWTToken', 'JWT authentication'],
  ['Z::AI::Resources::Chat::Completions', 'Chat API'],
  ['Z::AI::Resources::Embeddings', 'Embeddings API'],
  ['Z::AI::Resources::Images', 'Images API'],
  ['Z::AI::Resources::Files', 'Files API']
]

classes.each do |class_name, description|
  begin
    klass = Object.const_get(class_name)
    puts "  ✓ #{class_name} (#{description})"
    success_count += 1
  rescue => e
    puts "  ✗ #{class_name} - #{e.message}"
    errors << "Missing class: #{class_name}"
  end
end

# Test 4: Verify configuration works
puts "\n4. Testing configuration..."
begin
  config = Z::AI::Configuration.new
  config.api_key = 'test_key'
  config.validate!
  puts "  ✓ Configuration works"
  success_count += 1
rescue => e
  puts "  ✗ Configuration error: #{e.message}"
  errors << "Configuration error: #{e.message}"
end

# Test 5: Verify client initialization
puts "\n5. Testing client initialization..."
begin
  client = Z::AI::Client.new(api_key: 'test_key.12345')
  puts "  ✓ Client initialized"
  success_count += 1
rescue => e
  puts "  ✗ Client initialization error: #{e.message}"
  errors << "Client error: #{e.message}"
end

# Test 6: Verify API resources
puts "\n6. Testing API resources..."
begin
  client = Z::AI::Client.new(api_key: 'test_key.12345')
  
  resources = [
    [:chat, 'Chat API'],
    [:embeddings, 'Embeddings API'],
    [:images, 'Images API'],
    [:files, 'Files API']
  ]
  
  resources.each do |resource, name|
    if client.respond_to?(resource)
      obj = client.send(resource)
      puts "  ✓ #{name} accessible"
      success_count += 1
    else
      puts "  ✗ #{name} not accessible"
      errors << "Missing resource: #{resource}"
    end
  end
rescue => e
  puts "  ✗ Resource access error: #{e.message}"
  errors << "Resource error: #{e.message}"
end

# Test 7: Verify error classes
puts "\n7. Testing error classes..."
error_classes = [
  'Z::AI::Error',
  'Z::AI::APIStatusError',
  'Z::AI::APIAuthenticationError',
  'Z::AI::ValidationError'
]

error_classes.each do |error_class|
  begin
    klass = Object.const_get(error_class)
    error = klass.new(message: 'Test error')
    puts "  ✓ #{error_class}"
    success_count += 1
  rescue => e
    puts "  ✗ #{error_class} - #{e.message}"
    errors << "Error class issue: #{error_class}"
  end
end

# Test 8: Test JWT token generation
puts "\n8. Testing JWT token generation..."
begin
  token = Z::AI::Auth::JWTToken.generate_token('id.secret')
  puts "  ✓ JWT token generated"
  success_count += 1
rescue => e
  puts "  ✗ JWT error: #{e.message}"
  errors << "JWT error: #{e.message}"
end

# Summary
puts "\n" + "=" * 60
puts "VERIFICATION SUMMARY"
puts "=" * 60
puts "Total checks: #{success_count + errors.length}"
puts "Passed: #{success_count}"
puts "Failed: #{errors.length}"

if errors.empty?
  puts "\n✓ All verifications passed!"
  puts "\nThe SDK is ready for use."
  puts "\nNext steps:"
  puts "  - Run: bundle install"
  puts "  - Run: bundle exec rspec"
  puts "  - Try: ruby examples/basic_chat.rb"
  exit 0
else
  puts "\n✗ Some verifications failed:"
  errors.each { |error| puts "  - #{error}" }
  exit 1
end
