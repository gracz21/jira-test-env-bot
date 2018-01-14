module Jira
  module Request
    class Base
      def initialize(url:)
        @uri = URI(url)
      end

      def call
        jwt = generate_jwt
        request = build_request(jwt: jwt)
        make_request(request: request)
      end

      protected

      attr_reader :uri

      def generate_jwt
        claim = Atlassian::Jwt.build_claims(AppConfig.issuer, uri.to_s, self.class::HTTP_METHOD)
        JWT.encode(claim, AppConfig.shared_secret)
      end

      def make_request(request:)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        http.request(request)
      end
    end
  end
end
