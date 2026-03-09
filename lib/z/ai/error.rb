# frozen_string_literal: true

module Z
  module AI
    class Error < StandardError
      attr_reader :message, :code, :http_status, :http_body, :headers

      def initialize(message: nil, code: nil, http_status: nil, http_body: nil, headers: nil)
        @message = message
        @code = code
        @http_status = http_status
        @http_body = http_body
        @headers = headers || {}
        
        super(message)
      end

      def to_s
        msg = @message
        msg += " (code: #{@code})" if @code
        msg += " (status: #{@http_status})" if @http_status
        msg
      end
    end

    class APIStatusError < Error; end
    class APIRequestFailedError < APIStatusError; end
    class APIAuthenticationError < APIStatusError; end
    class APIConnectionError < APIStatusError; end
    class APITimeoutError < APIStatusError; end
    class APIResponseError < APIStatusError; end
    class APIResourceNotFoundError < APIStatusError; end
    class APIRateLimitError < APIStatusError; end
    class APIBadRequestError < APIStatusError; end

    class ConfigurationError < Error; end
    class ValidationError < Error; end
    class InvalidRequestError < Error; end
    class StreamingError < Error; end

    class JWTError < Error; end
    class JWTGenerationError < JWTError; end
    class JWTExpiredError < JWTError; end

    def self.raise_api_error(response)
      status = response.code
      body = response.body
      
      error_class = case status
                    when 400 then APIBadRequestError
                    when 401 then APIAuthenticationError
                    when 403 then APIAuthenticationError
                    when 404 then APIResourceNotFoundError
                    when 429 then APIRateLimitError
                    when 500..599 then APIRequestFailedError
                    else APIResponseError
                    end
      
      message = extract_error_message(body, status)
      
      raise error_class.new(
        message: message,
        http_status: status,
        http_body: body,
        headers: response.headers
      )
    end

    def self.extract_error_message(body, status)
      return "HTTP #{status}" unless body

      if body.is_a?(Hash)
        body.dig('error', 'message') ||
          body['error'] ||
          body['message'] ||
          "HTTP #{status}"
      else
        body.to_s[0..500]
      end
    end
    private_class_method :extract_error_message
  end
end
