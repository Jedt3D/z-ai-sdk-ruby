# frozen_string_literal: true

require_relative '../core/async_http_client'

module Z
  module AI
    module Resources
      module Chat
        class AsyncCompletions
          ENDPOINT = 'chat/completions'.freeze

          def initialize(client)
            @client = client
            @async_http = Core::AsyncHTTPClient.new(client.config)
          end

          def create(model:, messages:, **options)
            body = build_request_body(model, messages, false, options)
            
            @async_http.post_async(ENDPOINT, body: body)
          end

          private

          def build_request_body(model, messages, stream, options)
            body = {
              model: model,
              messages: normalize_messages(messages),
              stream: stream
            }

            options.each do |key, value|
              body[key] = value unless value.nil?
            end

            body
          end

          def normalize_messages(messages)
            messages.map do |msg|
              if msg.is_a?(Hash)
                msg
              elsif msg.is_a?(Models::Chat::Message)
                msg.to_h
              else
                raise ValidationError, "Invalid message type: #{msg.class}"
              end
            end
          end
        end
      end
    end
  end
end
