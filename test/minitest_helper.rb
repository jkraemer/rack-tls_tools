$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rack/tls_tools'

require 'rack/test'
require 'rack/mock'
require 'minitest/autorun'
require 'pry-nav'

class Minitest::Test
  include Rack::Test::Methods

  def app; Rack::Lint.new(@app); end

  def mock_app(middleware, options = {})
    main_app = lambda { |env|
      headers = {'Content-Type' => "text/html"}
      headers['Set-Cookie'] = "foo=bar; path=/; secure; HttpOnly\nx=y; path=/\na=b; secure"
      [200, headers, ['Hello world!']]
    }
    builder = Rack::Builder.new
    builder.use middleware, options
    builder.run main_app
    @app = builder.to_app
  end

end

