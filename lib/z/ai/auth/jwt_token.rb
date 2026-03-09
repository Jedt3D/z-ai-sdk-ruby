# frozen_string_literal: true

require 'jwt'
require 'time'

module Z
  module AI
    module Auth
      class JWTToken
        JWT_ALGORITHM = 'HS256'.freeze
        TOKEN_EXPIRY = 3600

        @@token_cache = {}
        @@cache_mutex = Mutex.new

        class << self
          def generate_token(api_key)
            raise JWTGenerationError.new(message: 'API key is required') unless api_key && !api_key.empty?

            cache_key = cache_key_for(api_key)
            
            @@cache_mutex.synchronize do
              if @@token_cache.key?(cache_key)
                cached = @@token_cache[cache_key]
                return cached[:token] if Time.now < cached[:expires_at]
              end

              token = create_token(api_key)
              @@token_cache[cache_key] = {
                token: token,
                expires_at: Time.now + (TOKEN_EXPIRY - 60)
              }
              token
            end
          end

          def clear_cache
            @@cache_mutex.synchronize do
              @@token_cache.clear
            end
          end

          def cache_stats
            @@cache_mutex.synchronize do
              {
                size: @@token_cache.size,
                keys: @@token_cache.keys
              }
            end
          end

          private

          def create_token(api_key)
            parts = api_key.split('.')
            raise JWTGenerationError.new(message: 'Invalid API key format') unless parts.length == 2

            id, secret = parts
            payload = {
              'api_key' => id,
              'exp' => (Time.now + TOKEN_EXPIRY).to_i,
              'timestamp' => Time.now.to_i
            }

            JWT.encode(payload, secret, JWT_ALGORITHM)
          end

          def cache_key_for(api_key)
            Digest::MD5.hexdigest(api_key)
          end
        end
      end
    end
  end
end
