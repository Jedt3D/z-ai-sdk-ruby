# frozen_string_literal: true

require_relative '../core/base_api'
require_relative '../models/files/response'

module Z
  module AI
    module Resources
      class Files < Core::BaseAPI
        ENDPOINT = 'files'.freeze

        VALID_PURPOSES = ['fine-tune', 'assistants', 'batch', 'vision'].freeze

        def list
          response = get(ENDPOINT)
          
          Models::Files::ListResponse.new(response.transform_keys(&:to_sym))
        rescue Dry::Struct::Error => e
          raise ValidationError, "Invalid response structure: #{e.message}"
        end

        def upload(file:, purpose:)
          validate_purpose(purpose)
          
          body = {
            file: file,
            purpose: purpose
          }

          response = post("#{ENDPOINT}/upload", body: body)
          
          Models::Files::FileInfo.new(response.transform_keys(&:to_sym))
        rescue Dry::Struct::Error => e
          raise ValidationError, "Invalid response structure: #{e.message}"
        end

        def retrieve(file_id)
          response = get("#{ENDPOINT}/#{file_id}")
          
          Models::Files::FileInfo.new(response.transform_keys(&:to_sym))
        rescue Dry::Struct::Error => e
          raise ValidationError, "Invalid response structure: #{e.message}"
        end

        def delete(file_id)
          response = delete("#{ENDPOINT}/#{file_id}")
          
          Models::Files::DeleteResponse.new(response.transform_keys(&:to_sym))
        rescue Dry::Struct::Error => e
          raise ValidationError, "Invalid response structure: #{e.message}"
        end

        def content(file_id)
          get("#{ENDPOINT}/#{file_id}/content")
        end

        private

        def validate_purpose(purpose)
          unless VALID_PURPOSES.include?(purpose.to_s)
            raise ValidationError, "Invalid purpose '#{purpose}'. Valid purposes: #{VALID_PURPOSES.join(', ')}"
          end
        end
      end
    end
  end
end
