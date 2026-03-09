# frozen_string_literal: true

require 'dry-struct'

module Z
  module AI
    module Models
      module Files
        module Types
          include Dry.Types()
        end

        class FileInfo < Dry::Struct
          attribute :id, Types::String
          attribute :object, Types::String
          attribute :bytes, Types::Integer
          attribute :created_at, Types::Integer
          attribute :filename, Types::String
          attribute :purpose, Types::String
          attribute? :status, Types::String.optional
          attribute? :status_details, Types::String.optional

          def to_h
            attributes.compact
          end
        end

        class ListResponse < Dry::Struct
          attribute :object, Types::String
          attribute :data, Types::Array.of(FileInfo)

          def to_h
            {
              object: object,
              data: data.map(&:to_h)
            }
          end

          def files
            data
          end
        end

        class DeleteResponse < Dry::Struct
          attribute :id, Types::String
          attribute :object, Types::String
          attribute :deleted, Types::Bool

          def to_h
            attributes
          end

          def deleted?
            deleted
          end
        end
      end
    end
  end
end
