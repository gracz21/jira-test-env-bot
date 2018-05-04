require_relative 'base'

module Jira
  module Request
    class Get < Base
      HTTP_METHOD = 'get'.freeze

      private

      def build_request(jwt:)
        request = Net::HTTP::Get.new(uri.request_uri)
        request.initialize_http_header('Authorization' => "JWT #{jwt}")

        request
      end
    end
  end
end
