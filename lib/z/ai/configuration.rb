# frozen_string_literal: true

require 'logger'

module Z
  module AI
    class Configuration
      attr_accessor :api_key,
                    :base_url,
                    :timeout,
                    :open_timeout,
                    :read_timeout,
                    :write_timeout,
                    :max_retries,
                    :retry_delay,
                    :logger,
                    :log_level,
                    :source_channel,
                    :disable_token_cache,
                    :custom_headers,
                    :proxy_url

      DEFAULT_BASE_URL = 'https://api.z.ai/api/paas/v4/'.freeze
      DEFAULT_TIMEOUT = 30
      DEFAULT_MAX_RETRIES = 3
      DEFAULT_RETRY_DELAY = 1

      def initialize
        @api_key = ENV['ZAI_API_KEY']
        @base_url = ENV['ZAI_BASE_URL'] || DEFAULT_BASE_URL
        @timeout = DEFAULT_TIMEOUT
        @open_timeout = DEFAULT_TIMEOUT
        @read_timeout = DEFAULT_TIMEOUT
        @write_timeout = DEFAULT_TIMEOUT
        @max_retries = DEFAULT_MAX_RETRIES
        @retry_delay = DEFAULT_RETRY_DELAY
        @logger = default_logger
        @log_level = ENV['ZAI_LOG_LEVEL']&.to_sym || :info
        @source_channel = 'ruby-sdk'
        @disable_token_cache = false
        @custom_headers = {}
        @proxy_url = ENV['ZAI_PROXY_URL']
      end

      def validate!
        raise ConfigurationError.new(message: 'API key is required') unless @api_key && !@api_key.empty?
        
        unless @base_url && !@base_url.empty?
          raise ConfigurationError.new(message: 'Base URL is required')
        end
        
        true
      end

      def merge(other)
        merged = dup
        other.instance_variables.each do |var|
          value = other.instance_variable_get(var)
          merged.instance_variable_set(var, value) unless value.nil?
        end
        merged
      end

      def to_h
        {
          api_key: @api_key,
          base_url: @base_url,
          timeout: @timeout,
          open_timeout: @open_timeout,
          read_timeout: @read_timeout,
          write_timeout: @write_timeout,
          max_retries: @max_retries,
          retry_delay: @retry_delay,
          source_channel: @source_channel,
          disable_token_cache: @disable_token_cache,
          custom_headers: @custom_headers,
          proxy_url: @proxy_url
        }
      end

      private

      def default_logger
        logger = Logger.new($stdout)
        logger.level = Logger::INFO
        logger.formatter = proc do |severity, datetime, _progname, msg|
          "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
        end
        logger
      end
    end
  end
end
