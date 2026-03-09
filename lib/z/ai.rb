# frozen_string_literal: true

require_relative 'ai/version'
require_relative 'ai/error'
require_relative 'ai/configuration'
require_relative 'ai/client'

module Z
  module AI
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration) if block_given?
      end

      def reset!
        @configuration = nil
      end

      def client
        @client ||= Client.new(configuration)
      end

      def method_missing(method, *args, &block)
        return super unless client.respond_to?(method)
        
        client.send(method, *args, &block)
      end

      def respond_to_missing?(method, include_private = false)
        client.respond_to?(method, include_private) || super
      end
    end
  end
end
