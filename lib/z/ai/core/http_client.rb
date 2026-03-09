# frozen_string_literal: true

require 'httparty'
require 'json'
require_relative '../error'

module Z
  module AI
    module Core
      class HTTPClient
        include HTTParty
        format :json
        headers 'Content-Type' => 'application/json'
        headers 'Accept' => 'application/json'

        attr_reader :config

        def initialize(config)
          @config = config
          configure_timeouts
          configure_proxy
        end

        def get(path, params: {}, headers: {})
          request(:get, path, params: params, headers: headers)
        end

        def post(path, body: {}, headers: {})
          request(:post, path, body: body, headers: headers)
        end

        def put(path, body: {}, headers: {})
          request(:put, path, body: body, headers: headers)
        end

        def patch(path, body: {}, headers: {})
          request(:patch, path, body: body, headers: headers)
        end

        def delete(path, headers: {})
          request(:delete, path, headers: headers)
        end

        def post_stream(path, body: {}, headers: {}, &block)
          request_stream(:post, path, body: body, headers: headers, &block)
        end

        def request(method, path, params: {}, body: {}, headers: {})
          url = build_url(path)
          request_headers = build_headers(headers)
          
          log_request(method, url, body)

          response = with_retry do
            self.class.send(method, url, {
              query: params,
              body: body.to_json,
              headers: request_headers
            })
          end

          handle_response(response)
        end

        def request_stream(method, path, body: {}, headers: {}, &block)
          url = build_url(path)
          request_headers = build_headers(headers.merge('Accept' => 'text/event-stream'))
          
          log_request(method, url, body)

          response = self.class.send(method, url, {
            body: body.to_json,
            headers: request_headers,
            stream_body: true
          }, &block)

          handle_stream_response(response)
        end

        private

        def configure_timeouts
          self.class.default_timeout(@config.timeout)
          self.class.open_timeout(@config.open_timeout)
          self.class.read_timeout(@config.read_timeout)
          self.class.write_timeout(@config.write_timeout)
        end

        def configure_proxy
          return unless @config.proxy_url
          
          uri = URI.parse(@config.proxy_url)
          self.class.http_proxy(uri.host, uri.port, uri.user, uri.password)
        end

        def build_url(path)
          base = @config.base_url.dup
          base = base.gsub(%r{/$}, '')
          path = path.gsub(%r{^/}, '')
          "#{base}/#{path}"
        end

        def build_headers(custom_headers = {})
          default_headers = {
            'User-Agent' => user_agent
          }
          
          auth_headers.merge(default_headers).merge(custom_headers)
        end

        def auth_headers
          {}
        end

        def user_agent
          "ZaiRubySdk/#{Z::AI::VERSION} Ruby/#{RUBY_VERSION} (#{RUBY_PLATFORM})"
        end

        def with_retry(retries: nil)
          max_retries = retries || @config.max_retries
          retry_count = 0
          delay = @config.retry_delay

          begin
            yield
          rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Net::OpenTimeout, Net::ReadTimeout => e
            retry_count += 1
            if retry_count <= max_retries
              sleep(delay * retry_count)
              retry
            end
            raise APITimeoutError.new(
              message: "Request timeout after #{max_retries} retries: #{e.message}",
              code: 'timeout'
            )
          end
        end

        def handle_response(response)
          log_response(response)

          unless response.success?
            Z::AI.raise_api_error(response)
          end

          response.parsed_response
        end

        def handle_stream_response(response)
          response
        end

        def log_request(method, url, body)
          return unless @config.logger
          
          safe_body = body.dup
          safe_body = filter_sensitive_data(safe_body) if safe_body.is_a?(Hash)
          
          @config.logger.info("[Z::AI] #{method.upcase} #{url}")
          @config.logger.debug("[Z::AI] Request Body: #{safe_body.to_json}")
        end

        def log_response(response)
          return unless @config.logger
          
          @config.logger.info("[Z::AI] Response Status: #{response.code}")
          @config.logger.debug("[Z::AI] Response Body: #{response.body[0..500]}")
        end

        def filter_sensitive_data(hash)
          filtered = hash.dup
          %w[api_key password token secret].each do |key|
            filtered[key] = '[FILTERED]' if filtered.key?(key)
          end
          filtered
        end
      end
    end
  end
end
