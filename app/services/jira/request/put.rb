module Jira
  module Request
    class Put < Base
      HTTP_METHOD = 'put'.freeze

      def initialize(url:, shared_secret:, body:)
        super(url: url, shared_secret: shared_secret)
        @body = body
      end

      private

      attr_reader :body

      def build_request(jwt:)
        request = Net::HTTP::Put.new(uri.request_uri)
        request.initialize_http_header('Authorization' => "JWT #{jwt}")
        request.body = body.to_json
        request.content_type = 'application/json'

        request
      end
    end
  end
end
