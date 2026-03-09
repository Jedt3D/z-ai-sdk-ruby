# frozen_string_literal: true

require 'dry-struct'

module Z
  module AI
    module Models
      module Chat
        module Types
          include Dry.Types()
        end

        class Message < Dry::Struct
          attribute :role, Types::String.enum('system', 'user', 'assistant', 'function', 'tool')
          attribute :content, Types::String | Types::Array
          attribute? :name, Types::String.optional
          attribute? :function_call, Types::Hash.optional
          attribute? :tool_calls, Types::Array.optional

          def to_h
            attributes.compact
          end
        end

        class Delta < Dry::Struct
          attribute? :role, Types::String.optional
          attribute? :content, Types::String.optional
          attribute? :function_call, Types::Hash.optional
          attribute? :tool_calls, Types::Array.optional

          def to_h
            attributes.compact
          end
        end

        class Choice < Dry::Struct
          attribute :index, Types::Integer
          attribute :message, Message.optional
          attribute? :delta, Delta.optional
          attribute? :finish_reason, Types::String.optional

          def to_h
            {
              index: index,
              message: message&.to_h,
              delta: delta&.to_h,
              finish_reason: finish_reason
            }.compact
          end
        end

        class Usage < Dry::Struct
          attribute :prompt_tokens, Types::Integer
          attribute :completion_tokens, Types::Integer
          attribute :total_tokens, Types::Integer

          def to_h
            attributes
          end
        end

        class Completion < Dry::Struct
          attribute :id, Types::String
          attribute :object, Types::String
          attribute :created, Types::Integer
          attribute :model, Types::String
          attribute :choices, Types::Array.of(Choice)
          attribute? :usage, Usage.optional
          attribute? :system_fingerprint, Types::String.optional

          def to_h
            {
              id: id,
              object: object,
              created: created,
              model: model,
              choices: choices.map(&:to_h),
              usage: usage&.to_h,
              system_fingerprint: system_fingerprint
            }.compact
          end

          def content
            choices.first&.message&.content
          end
        end

        class StreamChunk < Dry::Struct
          attribute :id, Types::String
          attribute :object, Types::String
          attribute :created, Types::Integer
          attribute :model, Types::String
          attribute :choices, Types::Array.of(Choice)

          def to_h
            {
              id: id,
              object: object,
              created: created,
              model: model,
              choices: choices.map(&:to_h)
            }
          end

          def delta_content
            choices.first&.delta&.content
          end
        end
      end
    end
  end
end
