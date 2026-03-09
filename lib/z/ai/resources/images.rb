# frozen_string_literal: true

require_relative '../core/base_api'
require_relative '../models/images/response'

module Z
  module AI
    module Resources
      class Images < Core::BaseAPI
        ENDPOINT = 'images/generations'.freeze

        VALID_SIZES = ['256x256', '512x512', '1024x1024', '1792x1792', '1024x1792', '1792x1024'].freeze
        VALID_FORMATS = ['url', 'b64_json'].freeze

        def generate(prompt:, model: 'cogview-3', **options)
          body = build_request_body(prompt, model, options)
          response = post(ENDPOINT, body: body)
          
          Models::Images::Response.new(response.transform_keys(&:to_sym))
        rescue Dry::Struct::Error => e
          raise ValidationError, "Invalid response structure: #{e.message}"
        end

        alias create generate

        private

        def build_request_body(prompt, model, options)
          body = {
            prompt: prompt,
            model: model
          }

          body[:n] = options[:n] || 1
          body[:size] = validate_size(options[:size]) if options[:size]
          body[:response_format] = validate_format(options[:response_format]) if options[:response_format]

          options.each do |key, value|
            body[key] = value unless body.key?(key) || value.nil?
          end

          body
        end

        def validate_size(size)
          unless VALID_SIZES.include?(size.to_s)
            raise ValidationError, "Invalid size '#{size}'. Valid sizes: #{VALID_SIZES.join(', ')}"
          end
          size.to_s
        end

        def validate_format(format)
          unless VALID_FORMATS.include?(format.to_s)
            raise ValidationError, "Invalid format '#{format}'. Valid formats: #{VALID_FORMATS.join(', ')}"
          end
          format.to_s
        end
      end
    end
  end
end
