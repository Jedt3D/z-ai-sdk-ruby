# frozen_string_literal: true

require 'async'
require 'async/http/client'
require 'async/http/endpoint'

module Z
  module AI
    module Core
      class AsyncHTTPClient
        def initialize(config)
          @config = config
        end

        def post_async(path, body: {}, headers: {})
          Async do
            endpoint = Async::HTTP::Endpoint.parse(build_url(path))
            client = Async::HTTP::Client.new(endpoint)
            
            request_headers = build_headers(headers)
            
            response = client.post(
              endpoint.path,
              body: body.to_json,
              headers: request_headers
            )
            
            result = handle_response(response)
            client.close
            
            result
          ensure
            client&.close
          end
        end

        def get_async(path, params: {}, headers: {})
          Async do
            endpoint = Async::HTTP::Endpoint.parse(build_url(path))
            client = Async::HTTP::Client.new(endpoint)
            
            request_headers = build_headers(headers)
            query_string = URI.encode_www_form(params) unless params.empty?
            path_with_query = query_string ? "#{endpoint.path}?#{query_string}" : endpoint.path
            
            response = client.get(path_with_query, headers: request_headers)
            
            result = handle_response(response)
            client.close
            
            result
          ensure
            client&.close
          end
        end

        private

        def build_url(path)
          base = @config.base_url.dup
          base = base.gsub(%r{/$}, '')
          path = path.gsub(%r{^/}, '')
          "#{base}/#{path}"
        end

        def build_headers(custom_headers = {})
          default_headers = {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'User-Agent' => "ZaiRubySdk/#{Z::AI::VERSION}"
          }
          
          auth_headers.merge(default_headers).merge(custom_headers)
        end

        def auth_headers
          if @config.disable_token_cache
            {
              'Authorization' => "Bearer #{@config.api_key}",
              'x-source-channel' => @config.source_channel
            }
          else
            {
              'Authorization' => "Bearer #{Auth::JWTToken.generate_token(@config.api_key)}",
              'x-source-channel' => @config.source_channel
            }
          end
        end

        def handle_response(response)
          status = response.status
          body = response.read
  
          unless (200..299).cover?(status)
            Z::AI.raise_api_error(OpenStruct.new(
              code: status,
              body: body,
              headers: response.headers
            ))
          end
  
          JSON.parse(body)
        end
      end
    end
  end
end
