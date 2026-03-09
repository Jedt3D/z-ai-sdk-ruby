# frozen_string_literal: true

require 'dry-struct'

module Z
  module AI
    module Models
      module Embeddings
        module Types
          include Dry.Types()
        end

        class EmbeddingData < Dry::Struct
          attribute :object, Types::String
          attribute :index, Types::Integer
          attribute :embedding, Types::Array.of(Types::Float)

          def to_h
            attributes
          end
        end

        class Usage < Dry::Struct
          attribute :prompt_tokens, Types::Integer
          attribute :total_tokens, Types::Integer

          def to_h
            attributes
          end
        end

        class Response < Dry::Struct
          attribute :object, Types::String
          attribute :data, Types::Array.of(EmbeddingData)
          attribute :model, Types::String
          attribute :usage, Usage

          def to_h
            {
              object: object,
              data: data.map(&:to_h),
              model: model,
              usage: usage.to_h
            }
          end

          def embeddings
            data.map(&:embedding)
          end

          def first_embedding
            data.first&.embedding
          end
        end
      end
    end
  end
end
