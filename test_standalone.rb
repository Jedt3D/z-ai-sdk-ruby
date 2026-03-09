#!/usr/bin/env ruby
# Standalone test that doesn't load the SDK
# Just verifies file structure and syntax

puts "=" * 70
puts "Z.ai Ruby SDK - Standalone Verification"
puts "Ruby: #{RUBY_VERSION} (#{RUBY_PLATFORM})"
puts "=" * 70

errors = []
passed = 0

# Test 1: File structure
puts "\n[File Structure]"
required_files = {
  'lib/z/ai.rb' => 'Main SDK file',
  'lib/z/ai/version.rb' => 'Version file',
  'lib/z/ai/client.rb' => 'Client',
  'lib/z/ai/configuration.rb' => 'Configuration',
  'lib/z/ai/error.rb' => 'Error classes',
  'lib/z/ai/core/http_client.rb' => 'HTTP client',
  'lib/z/ai/core/base_api.rb' => 'Base API',
  'lib/z/ai/auth/jwt_token.rb' => 'JWT auth',
  'lib/z/ai/resources/chat/completions.rb' => 'Chat API',
  'lib/z/ai/resources/embeddings.rb' => 'Embeddings API',
  'lib/z/ai/resources/images.rb' => 'Images API',
  'lib/z/ai/resources/files.rb' => 'Files API',
  'zai-ruby-sdk.gemspec' => 'Gemspec',
  'Gemfile' => 'Dependencies',
  'README.md' => 'Documentation'
}

required_files.each do |file, desc|
  if File.exist?(file)
    puts "  ✓ #{desc}"
    passed += 1
  else
    puts "  ✗ #{desc} (#{file})"
    errors << "Missing: #{file}"
  end
end

# Test 2: Ruby syntax
puts "\n[Ruby Syntax]"
ruby_files = Dir['lib/**/*.rb'].first(5) # Check first 5 files

ruby_files.each do |file|
  result = `ruby -c #{file} 2>&1`
  if $?.success?
    puts "  ✓ #{File.basename(file)}"
    passed += 1
  else
    puts "  ✗ #{File.basename(file)}"
    errors << "Syntax error: #{file}"
  end
end

# Test 3: Documentation
puts "\n[Documentation]"
%w[README.md CHANGELOG.md TESTING.md QUICKSTART.md].each do |doc|
  if File.exist?(doc)
    size = File.size(doc)
    puts "  ✓ #{doc} (#{size} bytes)"
    passed += 1
  else
    puts "  ✗ #{doc}"
    errors << "Missing: #{doc}"
  end
end

# Test 4: Docker files
puts "\n[Docker Configuration]"
docker_files = %w[
  docker/Dockerfile.ruby
  docker/Dockerfile.jruby
  docker/docker-compose.yml
  test_all_environments.sh
]

docker_files.each do |file|
  if File.exist?(file)
    puts "  ✓ #{file}"
    passed += 1
  else
    puts "  ✗ #{file}"
    errors << "Missing: #{file}"
  end
end

# Summary
puts "\n" + "=" * 70
puts "SUMMARY"
puts "=" * 70
puts "Passed: #{passed}"
puts "Errors: #{errors.length}"

if errors.empty?
  puts "\n✅ All structure checks passed!"
  puts "\nTo fully test the SDK:"
  puts "  1. ./test_all_environments.sh local"
  puts "  2. ./test_all_environments.sh docker"
  exit 0
else
  puts "\n❌ Some checks failed:"
  errors.first(5).each { |e| puts "  - #{e}" }
  exit 1
end
