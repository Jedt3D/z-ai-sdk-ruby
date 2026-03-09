#!/usr/bin/env ruby
# frozen_string_literal: true

# Smoke test to verify SDK structure is correct
# Run this after bundle install to verify basic functionality

puts "Z.ai Ruby SDK - Smoke Test"
puts "=" * 60

errors = []
success_count = 0

# Test 1: Check if main files exist
puts "\n1. Checking file structure..."
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
  'lib/z/ai/models/chat/completion.rb',
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

# Test 2: Check if directories exist
puts "\n2. Checking directories..."
required_dirs = [
  'lib/z/ai/core',
  'lib/z/ai/auth',
  'lib/z/ai/resources/chat',
  'lib/z/ai/models/chat',
  'spec/core',
  'spec/auth',
  'spec/resources/chat',
  'spec/models/chat',
  'examples'
]

required_dirs.each do |dir|
  if Dir.exist?(dir)
    puts "  ✓ #{dir}/"
    success_count += 1
  else
    puts "  ✗ #{dir}/ - MISSING"
    errors << "Missing directory: #{dir}"
  end
end

# Test 3: Try to parse Ruby files
puts "\n3. Checking Ruby syntax..."
ruby_files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']

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

# Test 4: Check examples
puts "\n4. Checking examples..."
examples = Dir['examples/*.rb']
examples.each do |example|
  if File.exist?(example)
    puts "  ✓ #{example}"
    success_count += 1
  else
    puts "  ✗ #{example} - MISSING"
    errors << "Missing example: #{example}"
  end
end

# Test 5: Check spec files
puts "\n5. Checking test files..."
specs = Dir['spec/**/*_spec.rb']
specs.each do |spec|
  if File.exist?(spec)
    puts "  ✓ #{spec}"
    success_count += 1
  else
    puts "  ✗ #{spec} - MISSING"
    errors << "Missing spec: #{spec}"
  end
end

# Summary
puts "\n" + "=" * 60
puts "SUMMARY"
puts "=" * 60
puts "Total checks: #{success_count + errors.length}"
puts "Passed: #{success_count}"
puts "Failed: #{errors.length}"

if errors.empty?
  puts "\n✓ All checks passed!"
  puts "\nNext steps:"
  puts "  1. Run: bundle install"
  puts "  2. Run: bundle exec rspec"
  puts "  3. Try an example: ruby examples/basic_chat.rb"
  exit 0
else
  puts "\n✗ Some checks failed:"
  errors.each { |error| puts "  - #{error}" }
  exit 1
end
