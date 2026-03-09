# frozen_string_literal: true

require_relative 'ai'

module ZaiRubySdk
  class << self
    def method_missing(method, *args, &block)
      return super unless Z::AI.respond_to?(method)
      
      Z::AI.send(method, *args, &block)
    end

    def respond_to_missing?(method, include_private = false)
      Z::AI.respond_to?(method, include_private) || super
    end
  end
end

Zai = ZaiRubySdk unless defined?(Zai)
