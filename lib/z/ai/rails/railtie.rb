# frozen_string_literal: true

module Z
  module AI
    class Railtie < ::Rails::Railtie
      initializer 'z_ai.configure' do |app|
        config_file = Rails.root.join('config', 'z_ai.yml')
        
        if config_file.exist?
          config_data = YAML.load_file(config_file)[Rails.env] || {}
          
          Z::AI.configure do |config|
            config.api_key = config_data['api_key'] || ENV['ZAI_API_KEY']
            config.base_url = config_data['base_url'] if config_data['base_url']
            config.timeout = config_data['timeout'] if config_data['timeout']
            config.max_retries = config_data['max_retries'] if config_data['max_retries']
            config.logger = Rails.logger
            config.log_level = Rails.env.production? ? :info : :debug
            config.source_channel = 'ruby-sdk-rails'
            config.disable_token_cache = config_data['disable_token_cache'] || false
          end
        end

        if defined?(ActiveSupport::Notifications)
          ActiveSupport::Notifications.subscribe('request.z_ai') do |name, start, finish, id, payload|
            Rails.logger.debug("[Z::AI] Request completed in #{(finish - start) * 1000}ms")
          end
        end
      end

      rake_tasks do
        load File.expand_path('../tasks/z_ai.rake', __FILE__)
      end

      generators do
        load File.expand_path('../generators/install_generator.rb', __FILE__) if File.exist?(File.expand_path('../generators/install_generator.rb', __FILE__))
      end

      console do |app|
        console_message = <<~MSG
          Z.ai Ruby SDK Console Helper
          =============================

          Available helpers:
            zai_client - Returns configured Z::AI::Client instance

          Example:
            zai_client.chat.completions.create(
              model: 'glm-5',
              messages: [{ role: 'user', content: 'Hello!' }]
            )
        MSG

        puts console_message
      end
    end
  end
end
