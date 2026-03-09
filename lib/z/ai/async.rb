# frozen_string_literal: true

require_relative 'ai'
require_relative 'ai/rails/railtie' if defined?(Rails::Railtie)
require_relative 'ai/rails/active_job' if defined?(ActiveJob)

module Z
  module AI
    class << self
      def async
        @async_client ||= AsyncClient.new(configuration)
      end
    end

    class AsyncClient
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def chat
        @chat ||= Resources::Chat::AsyncCompletions.new(Client.new(config))
      end

      def embeddings
        @embeddings ||= Resources::AsyncEmbeddings.new(Client.new(config))
      end
    end
  end
end
