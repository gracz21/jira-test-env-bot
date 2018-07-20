module Jira
  module Request
    class Base
      def initialize(url:, shared_secret:)
        @uri = URI(url)
        @shared_secret = shared_secret
      end

      def call
        jwt = generate_jwt
        request = build_request(jwt: jwt)
        make_request(request: request)
      end

      protected

      attr_reader :uri, :shared_secret

      def generate_jwt
        claim = Atlassian::Jwt.build_claims(
          ENV['ADDON_KEY'],
          uri.to_s,
          self.class::HTTP_METHOD
        )
        JWT.encode(claim, shared_secret)
      end

      def make_request(request:)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'

        http.request(request)
      end
    end
  end
end
