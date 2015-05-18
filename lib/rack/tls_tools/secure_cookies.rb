module Rack
  module TlsTools

    class SecureCookies

      def initialize(app, *args)
        @app = app
      end

      def call(env)
        @app.call(env).tap do |response|
          @request = Rack::Request.new env
          if @request.ssl?
            secure_cookies! response[1]
          end
        end
      end

      private

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


