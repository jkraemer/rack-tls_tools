module Rack
  module TlsTools

    # http://en.wikipedia.org/wiki/Strict_Transport_Security
    class Hsts

      # a year
      DEFAULT_MAX_AGE = 3600 * 24 * 365

      def initialize(app, options = {})
        @app = app
        @options = {
          enable: true,
          max_age: DEFAULT_MAX_AGE,
          subdomains: false,
        }.merge(options)
      end

      def call(env)
        @app.call(env).tap do |response|
          @request = Rack::Request.new env
          if @request.ssl? && @options[:enable]
            add_hsts_header! response[1]
          end
        end
      end

      private

      def add_hsts_header!(headers)
        val = "max-age=#{@options[:max_age]}"
        val += "; includeSubDomains" if @options[:subdomains]
        headers['Strict-Transport-Security'] = val
      end

    end
  end
end
