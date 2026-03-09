#!/usr/bin/env ruby
# frozen_string_literal: true

# Isolated verification script that doesn't require external dependencies
# Tests core SDK functionality by loading files directly

puts "=" * 70
puts "Z.ai Ruby SDK - Isolated Verification Test"
puts "Ruby Version: #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"
puts "Platform: #{RUBY_PLATFORM}"
puts "=" * 70

# Add lib to load path
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

tests = []
passed = 0
failed = 0

def run_test(name)
  print "#{name}... "
  begin
    result = yield
    if result
      puts "✓ PASS"
      return true
    else
      puts "✗ FAIL (returned false)"
      return false
    end
  rescue => e
    puts "✗ FAIL"
    puts "  Error: #{e.class} - #{e.message}"
    puts "  Location: #{e.backtrace[0]}" if e.backtrace&.any?
    return false
  end
end

# Test 1: Load core files without dependencies
puts "\n[Phase 1: Core File Loading]"

if run_test("Load version") do
  require 'z/ai/version'
  defined?(Z::AI::VERSION) && !Z::AI::VERSION.empty?
end
  passed += 1
else
  failed += 1
end

if run_test("Load error classes") do
  require 'z/ai/error'
  defined?(Z::AI::Error) && defined?(Z::AI::ValidationError)
end
  passed += 1
else
  failed += 1
end

if run_test("Load configuration") do
  require 'z/ai/configuration'
  defined?(Z::AI::Configuration)
end
  passed += 1
else
  failed += 1
end

# Test 2: Test configuration functionality
puts "\n[Phase 2: Configuration]"

if run_test("Create configuration") do
  config = Z::AI::Configuration.new
  config.is_a?(Z::AI::Configuration)
end
  passed += 1
else
  failed += 1
end

if run_test("Set configuration values") do
  config = Z::AI::Configuration.new
  config.api_key = 'test_key.12345'
  config.timeout = 60
  config.api_key == 'test_key.12345' && config.timeout == 60
end
  passed += 1
else
  failed += 1
end

if run_test("Validate configuration (should fail without key)") do
  config = Z::AI::Configuration.new
  begin
    config.validate!
    false  # Should have raised error
  rescue Z::AI::ConfigurationError
    true  # Expected
  end
end
  passed += 1
else
  failed += 1
end

if run_test("Validate configuration (should pass with key)") do
  config = Z::AI::Configuration.new
  config.api_key = 'valid_key'
  result = config.validate!
  result == true
end
  passed += 1
else
  failed += 1
end

# Test 3: Test error classes
puts "\n[Phase 3: Error Handling]"

if run_test("Create base error") do
  error = Z::AI::Error.new(message: 'Test error')
  error.message == 'Test error'
end
  passed += 1
else
  failed += 1
end

if run_test("Create API error with context") do
  error = Z::AI::APIAuthenticationError.new(
    message: 'Auth failed',
    http_status: 401,
    code: 'unauthorized'
  )
  error.http_status == 401 && error.code == 'unauthorized'
end
  passed += 1
else
  failed += 1
end

if run_test("Error to_s includes context") do
  error = Z::AI::APIStatusError.new(
    message: 'API error',
    code: 'test_code',
    http_status: 500
  )
  str = error.to_s
  str.include?('API error') && str.include?('test_code') && str.include?('500')
end
  passed += 1
else
  failed += 1
end

# Test 4: Load remaining core files (may require dependencies)
puts "\n[Phase 4: Dependency-Heavy Components]"

begin
  if run_test("Load JWT auth (requires jwt gem)") do
    require 'z/ai/auth/jwt_token'
    defined?(Z::AI::Auth::JWTToken)
  end
    passed += 1
  else
    failed += 1
    puts "  (Skipping JWT tests - jwt gem not available)"
  end
  
  if defined?(Z::AI::Auth::JWTToken)
    if run_test("Generate JWT token") do
      token = Z::AI::Auth::JWTToken.generate_token('id.secret')
      token.is_a?(String) && token.split('.').length == 3
    end
      passed += 1
    else
      failed += 1
    end
  end
rescue LoadError => e
  puts "Skipping JWT tests: #{e.message}"
end

begin
  if run_test("Load client (requires httparty)") do
    require 'z/ai/client'
    defined?(Z::AI::Client)
  end
    passed += 1
  else
    failed += 1
    puts "  (Skipping client tests - httparty gem not available)"
  end
  
  if defined?(Z::AI::Client)
    if run_test("Initialize client") do
      client = Z::AI::Client.new(api_key: 'test_key.12345')
      client.is_a?(Z::AI::Client)
    end
      passed += 1
    else
      failed += 1
    end
    
    if run_test("Access chat resource") do
      client = Z::AI::Client.new(api_key: 'test_key.12345')
      chat = client.chat
      defined?(chat) && chat.respond_to?(:create)
    end
      passed += 1
    else
      failed += 1
    end
  end
rescue LoadError => e
  puts "Skipping client tests: #{e.message}"
end

# Summary
puts "\n" + "=" * 70
puts "VERIFICATION SUMMARY"
puts "=" * 70
puts "Tests Run: #{passed + failed}"
puts "Passed: #{passed}"
puts "Failed: #{failed}"
puts ""

if failed == 0
  puts "✅ All verification tests passed!"
  puts "\nThe SDK core components are working correctly."
  puts "\nNext steps:"
  puts "  • Install dependencies: bundle install"
  puts "  • Run full tests: bundle exec rspec"
  puts "  • Try examples: ruby examples/basic_chat.rb"
  exit 0
else
  puts "❌ #{failed} test(s) failed"
  puts "\nSome components may be missing dependencies."
  puts "Install with: bundle install"
  exit 1
end
