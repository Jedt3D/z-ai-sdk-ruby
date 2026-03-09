#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple smoke test that can run without full test dependencies
# This verifies basic SDK functionality and structure

puts "Z.ai Ruby SDK - Smoke Test"
puts "=" * 70

errors = []
success_count = 0

# Test 1: Check project structure
puts "\n1. Checking project structure..."
required_files = [
  'lib/z/ai.rb',
  'lib/z/ai/version.rb',
  'lib/z/ai/client.rb',
  'lib/z/ai/configuration.rb',
  'lib/z/ai/error.rb',
  'lib/z/ai/core/http_client.rb',
  'lib/z/ai/core/base_api.rb',
  'lib/z/ai/auth/jwt_token.rb',
  'lib/z/ai/resources/chat/completions.rb',
  'lib/z/ai/resources/embeddings.rb',
  'lib/z/ai/resources/images.rb',
  'lib/z/ai/resources/files.rb',
  'zai-ruby-sdk.gemspec',
  'Gemfile',
  'Rakefile',
  'README.md'
]

required_files.each do |file|
  if File.exist?(file)
    puts "  ✓ #{file}"
    success_count += 1
  else
    puts "  ✗ #{file} - MISSING"
    errors << "Missing file: #{file}"
  end
end

# Test 2: Check Ruby syntax
puts "\n2. Checking Ruby syntax..."
ruby_files = Dir['lib/**/*.rb']

ruby_files.each do |file|
  result = system("ruby -c #{file} > /dev/null 2>&1")
  if result
    puts "  ✓ #{file}"
    success_count += 1
  else
    puts "  ✗ #{file} - SYNTAX ERROR"
    errors << "Syntax error in: #{file}"
  end
end

# Test 3: Check RSpec files
puts "\n3. Checking RSpec files..."
spec_files = Dir['spec/**/*_spec.rb']

spec_files.each do |file|
  if File.exist?(file)
    puts "  ✓ #{file}"
    success_count += 1
  else
    puts "  ✗ #{file} - MISSING"
    errors << "Missing spec: #{file}"
  end
end

# Test 4: Check example files
puts "\n4. Checking example files..."
example_files = Dir['examples/*.rb']

example_files.each do |file|
  if File.exist?(file)
    puts "  ✓ #{file}"
    success_count += 1
  else
    puts "  ✗ #{file} - MISSING"
    errors << "Missing example: #{file}"
  end
end

# Test 5: Check documentation
puts "\n5. Checking documentation..."
doc_files = %w[README.md CHANGELOG.md CONTRIBUTING.md CODE_OF_CONDUCT.md QUICKSTART.md]

doc_files.each do |file|
  if File.exist?(file)
    puts "  ✓ #{file}"
    success_count += 1
  else
    puts "  ✗ #{file} - MISSING"
    errors << "Missing doc: #{file}"
  end
end

# Test 6: Check Docker files
puts "\n6. Checking Docker configuration..."
docker_files = [
  'docker/Dockerfile.ruby',
  'docker/Dockerfile.jruby',
  'docker/docker-compose.yml',
  'test_all_environments.sh'
]

docker_files.each do |file|
  if File.exist?(file)
    puts "  ✓ #{file}"
    success_count += 1
  else
    puts "  ✗ #{file} - MISSING"
    errors << "Missing Docker file: #{file}"
  end
end

# Test 7: Version consistency
puts "\n7. Checking version..."
begin
  require_relative 'lib/z/ai/version'
  version = Z::AI::VERSION
  
  if version && !version.empty?
    puts "  ✓ Version: #{version}"
    success_count += 1
  else
    puts "  ✗ Invalid version"
    errors << "Invalid version"
  end
rescue => e
  puts "  ✗ Could not load version: #{e.message}"
  errors << "Version check failed: #{e.message}"
end

# Test 8: Gemspec validity
puts "\n8. Checking gemspec..."
gemspec_file = 'zai-ruby-sdk.gemspec'
if File.exist?(gemspec_file)
  begin
    # Try to load the gemspec
    eval(File.read(gemspec_file), binding, gemspec_file)
    puts "  ✓ Gemspec is valid"
    success_count += 1
  rescue => e
    puts "  ✗ Gemspec error: #{e.message}"
    errors << "Gemspec invalid: #{e.message}"
  end
else
  puts "  ✗ Gemspec not found"
  errors << "Missing gemspec"
end

# Summary
puts "\n" + "=" * 70
puts "SUMMARY"
puts "=" * 70
puts "Total checks: #{success_count + errors.length}"
puts "Passed: #{success_count}"
puts "Failed: #{errors.length}"

if errors.empty?
  puts "\n✓ All smoke tests passed!"
  puts "\nNext steps:"
  puts "  1. Run: ./test_all_environments.sh local    # Local verification"
  puts "  2. Run: ./test_all_environments.sh docker   # Docker tests"
  puts "  3. Run: ./test_all_environments.sh all      # Complete test suite"
  exit 0
else
  puts "\n✗ Some smoke tests failed:"
  errors.each { |error| puts "  - #{error}" }
  exit 1
end
