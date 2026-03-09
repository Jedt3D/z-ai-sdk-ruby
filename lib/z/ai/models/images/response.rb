# frozen_string_literal: true

require 'dry-struct'

module Z
  module AI
    module Models
      module Images
        module Types
          include Dry.Types()
        end

        class ImageData < Dry::Struct
          attribute? :url, Types::String.optional
          attribute? :b64_json, Types::String.optional
          attribute? :revised_prompt, Types::String.optional

          def to_h
            attributes.compact
          end
        end

        class Response < Dry::Struct
          attribute :created, Types::Integer
          attribute :data, Types::Array.of(ImageData)

          def to_h
            {
              created: created,
              data: data.map(&:to_h)
            }
          end

          def urls
            data.map(&:url).compact
          end

          def first_url
            data.first&.url
          end

          def base64_images
            data.map(&:b64_json).compact
          end
        end
      end
    end
  end
end
