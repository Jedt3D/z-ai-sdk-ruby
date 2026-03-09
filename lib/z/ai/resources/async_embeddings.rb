# frozen_string_literal: true

require_relative '../core/async_http_client'

module Z
  module AI
    module Resources
      class AsyncEmbeddings
        ENDPOINT = 'embeddings'.freeze

        def initialize(client)
          @client = client
          @async_http = Core::AsyncHTTPClient.new(client.config)
        end

        def create(input:, model:, **options)
          body = build_request_body(input, model, options)
          
          @async_http.post_async(ENDPOINT, body: body).then do |response|
            Models::Embeddings::Response.new(response.transform_keys(&:to_sym))
          end
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
