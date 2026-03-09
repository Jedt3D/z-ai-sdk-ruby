# frozen_string_literal: true

require_relative 'core/http_client'
require_relative 'core/base_api'
require_relative 'auth/jwt_token'
require_relative 'resources/chat/completions'
require_relative 'resources/chat/async_completions'
require_relative 'resources/embeddings'
require_relative 'resources/async_embeddings'
require_relative 'resources/images'
require_relative 'resources/files'

module Z
  module AI
    class Client < Core::HTTPClient
      attr_reader :config, :http_client

      def initialize(config_or_options = {})
        @config = config_or_options.is_a?(Configuration) ? config_or_options : build_config(config_or_options)
        @config.validate!
        super(@config)
        @http_client = self
      end

      def chat
        @chat ||= Resources::Chat::Completions.new(self)
      end

      def async_chat
        @async_chat ||= Resources::Chat::AsyncCompletions.new(self)
      end

      def embeddings
        @embeddings ||= Resources::Embeddings.new(self)
      end

      def async_embeddings
        @async_embeddings ||= Resources::AsyncEmbeddings.new(self)
      end

      def images
        @images ||= Resources::Images.new(self)
      end

      def files
        @files ||= Resources::Files.new(self)
      end

      private

      def build_config(options)
        config = Configuration.new
        options.each do |key, value|
          config.send("#{key}=", value) if config.respond_to?("#{key}=")
        end
        config
      end

      def auth_headers
        if @config.disable_token_cache
          {
            'Authorization' => "Bearer #{@config.api_key}",
            'x-source-channel' => @config.source_channel
          }
        else
          {
            'Authorization' => "Bearer #{Auth::JWTToken.generate_token(@config.api_key)}",
            'x-source-channel' => @config.source_channel
          }
        end
      end

      def handle_stream_response(response)
        return response unless block_given?

        response.body.each do |chunk|
          yield chunk
        end
      end
    end

    class ZhipuClient < Client
      ZHIPU_BASE_URL = 'https://open.bigmodel.cn/api/paas/v4/'.freeze

      def initialize(config_or_options = {})
        if config_or_options.is_a?(Hash)
          config_or_options[:base_url] ||= ZHIPU_BASE_URL
        end
        super(config_or_options)
      end
    end
  end
end
