# frozen_string_literal: true

require_relative '../core/base_api'
require_relative '../models/embeddings/response'

module Z
  module AI
    module Resources
      class Embeddings < Core::BaseAPI
        ENDPOINT = 'embeddings'.freeze

        def create(input:, model:, **options)
          body = build_request_body(input, model, options)
          response = post(ENDPOINT, body: body)
          
          Models::Embeddings::Response.new(response.transform_keys(&:to_sym))
        rescue Dry::Struct::Error => e
          raise ValidationError, "Invalid response structure: #{e.message}"
        end

        private

        def build_request_body(input, model, options)
          body = {
            input: normalize_input(input),
            model: model
          }

          options.each do |key, value|
            body[key] = value unless value.nil?
          end

          body
        end

        def normalize_input(input)
          case input
          when String
            input
          when Array
            input
          else
            raise ValidationError, "Input must be a string or array of strings"
          end
        end
      end
    end
  end
end
