module Rack
  module TlsTools

    class SecureCookies

      def initialize(app, options = {})
        @app = app
        @enabled = options.key?(:enable) ? options[:enable] : true
        @hosts = options[:hosts]
      end

      def call(env)
        @app.call(env).tap do |response|
          @request = Rack::Request.new env
          if @request.ssl? && use_for_host?(@request.host)
            secure_cookies! response[1]
          end
        end
      end

      private

      def use_for_host?(host)
        @enabled && (@hosts.nil? || @hosts.include?(host))
      end

      def secure_cookies!(headers)
        if cookies = headers['Set-Cookie']
          headers['Set-Cookie'] = cookies.split("\n").map do |cookie|
            cookie =~ /(^|;\s*)secure($|\s*;)/ ? cookie : cookie + '; secure'
          end.join("\n")
        end
      end

    end

  end
end


