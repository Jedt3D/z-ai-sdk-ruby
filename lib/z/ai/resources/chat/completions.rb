# frozen_string_literal: true

require_relative '../../core/base_api'
require_relative '../../models/chat/completion'

module Z
  module AI
    module Resources
      module Chat
        class Completions < Core::BaseAPI
          ENDPOINT = 'chat/completions'.freeze

          def create(model:, messages:, stream: false, **options)
            body = build_request_body(model, messages, stream, options)
            
            if stream
              create_stream(body)
            else
              create_sync(body)
            end
          end

          def create_async(model:, messages:, **options)
            raise NotImplementedError, 'Async completions are not yet implemented for Ruby < 3.2'
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

          def create_sync(body)
            response = post(ENDPOINT, body: body)
            Models::Chat::Completion.new(response.transform_keys(&:to_sym))
          rescue Dry::Struct::Error => e
            raise ValidationError, "Invalid response structure: #{e.message}"
          end

          def create_stream(body)
            StreamIterator.new(@client, ENDPOINT, body)
          end
        end

        class StreamIterator
          include Enumerable

          def initialize(client, endpoint, body)
            @client = client
            @endpoint = endpoint
            @body = body
          end

          def each(&block)
            return enum_for(:each) unless block_given?

            buffer = ''
            
            @client.http_client.post_stream(@endpoint, body: @body) do |chunk|
              buffer += chunk
              
              while (line = buffer.slice!(/.*?\n/))
                process_line(line.strip, &block)
              end
            end

            process_line(buffer.strip, &block) if buffer.length > 0
          end

          private

          def process_line(line)
            return if line.empty?
            return unless line.start_with?('data: ')

            data = line[6..-1]
            return if data == '[DONE]'

            begin
              parsed = JSON.parse(data)
              chunk = Models::Chat::StreamChunk.new(parsed.transform_keys(&:to_sym))
              yield chunk
            rescue JSON::ParserError => e
              raise StreamingError, "Failed to parse streaming chunk: #{e.message}"
            rescue Dry::Struct::Error => e
              raise ValidationError, "Invalid stream chunk structure: #{e.message}"
            end
          end
        end
      end
    end
  end
end
