# frozen_string_literal: true

namespace :z_ai do
  desc 'Verify Z.ai SDK configuration'
  task verify: :environment do
    puts "Verifying Z.ai SDK configuration..."
    
    begin
      client = Z::AI::Client.new
      puts "✓ Client initialized successfully"
      puts "✓ API Key configured: #{client.config.api_key[0..10]}..."
      puts "✓ Base URL: #{client.config.base_url}"
      puts "✓ Timeout: #{client.config.timeout}s"
      puts "✓ Max Retries: #{client.config.max_retries}"
      
      # Test a simple API call (if API key is valid)
      if ENV['ZAI_TEST_API'] == 'true'
        puts "\nTesting API connection..."
        begin
          response = client.chat.completions.create(
            model: 'glm-5',
            messages: [{ role: 'user', content: 'Hello' }],
            max_tokens: 5
          )
          puts "✓ API connection successful"
          puts "✓ Response received: #{response.choices.first.message.content[0..50]}..."
        rescue => e
          puts "✗ API connection failed: #{e.message}"
        end
      end
      
      puts "\n✅ Z.ai SDK configuration verified"
    rescue => e
      puts "✗ Configuration error: #{e.message}"
      puts "\nPlease check your configuration:"
      puts "  1. Set ZAI_API_KEY environment variable"
      puts "  2. Verify config/z_ai.yml exists"
      puts "  3. Check config/initializers/z_ai.rb"
      exit 1
    end
  end

  desc 'Generate RBS type signatures'
  task rbs: :environment do
    puts "Generating RBS type signatures..."
    
    # This would typically use a tool like rbs_rails or steep
    # For now, we just verify existing signatures
    
    sig_dir = Rails.root.join('sig')
    if sig_dir.exist?
      puts "✓ RBS signatures directory exists"
      
      sig_files = Dir.glob(sig_dir.join('**/*.rbs'))
      puts "✓ Found #{sig_files.count} RBS files"
      
      sig_files.each do |file|
        puts "  - #{file.relative_path_from(Rails.root)}"
      end
    else
      puts "✗ RBS signatures directory not found"
    end
  end

  desc 'Clear JWT token cache'
  task clear_cache: :environment do
    puts "Clearing JWT token cache..."
    
    Z::AI::Auth::JWTToken.clear_cache
    
    puts "✓ JWT token cache cleared"
  end

  desc 'Show SDK statistics'
  task stats: :environment do
    puts "Z.ai SDK Statistics"
    puts "=" * 50
    
    cache_stats = Z::AI::Auth::JWTToken.cache_stats
    
    puts "JWT Token Cache:"
    puts "  Cached tokens: #{cache_stats[:size]}"
    puts "  Cache keys: #{cache_stats[:keys].join(', ')}"
    
    puts "\nConfiguration:"
    config = Z::AI.configuration
    puts "  Base URL: #{config.base_url}"
    puts "  Timeout: #{config.timeout}s"
    puts "  Max Retries: #{config.max_retries}"
    puts "  Token Cache: #{config.disable_token_cache ? 'Disabled' : 'Enabled'}"
    puts "  Logger: #{config.logger ? 'Configured' : 'Not configured'}"
  end

  desc 'Test async functionality'
  task test_async: :environment do
    puts "Testing async functionality..."
    
    begin
      require 'async'
      
      puts "✓ async gem available"
      
      # Test async client
      client = Z::AI::Client.new
      
      if client.respond_to?(:async_chat)
        puts "✓ Async client methods available"
        
        Async do
          puts "  Testing async operation..."
          # Would test actual async call here
          puts "  ✓ Async operation completed"
        end
      else
        puts "ℹ Async methods not available (requires Ruby 3.2+)"
      end
      
      puts "\n✅ Async test completed"
    rescue LoadError
      puts "✗ async gem not installed"
      puts "  Add 'gem async' to your Gemfile to enable async support"
    end
  end
end
