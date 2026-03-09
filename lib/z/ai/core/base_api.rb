# frozen_string_literal: true

module Z
  module AI
    module Core
      class BaseAPI
        attr_reader :client

        def initialize(client)
          @client = client
        end

        protected

        def get(path, params: {}, headers: {})
          @client.http_client.get(path, params: params, headers: headers)
        end

        def post(path, body: {}, headers: {})
          @client.http_client.post(path, body: body, headers: headers)
        end

        def put(path, body: {}, headers: {})
          @client.http_client.put(path, body: body, headers: headers)
        end

        def patch(path, body: {}, headers: {})
          @client.http_client.patch(path, body: body, headers: headers)
        end

        def delete(path, headers: {})
          @client.http_client.delete(path, headers: headers)
        end

        def post_stream(path, body: {}, headers: {}, &block)
          @client.http_client.post_stream(path, body: body, headers: headers, &block)
        end
      end
    end
  end
end
