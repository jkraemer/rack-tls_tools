require 'minitest_helper'

class HstsTest < Minitest::Test
  def setup
    mock_app Rack::TlsTools::Hsts, subdomains: true
  end

  def test_should_add_hsts_header
    get 'https://test.host/'
    assert_equal "max-age=#{Rack::TlsTools::Hsts::DEFAULT_MAX_AGE}; includeSubDomains", last_response.headers["Strict-Transport-Security"]
  end

  def test_should_not_modify_nonssl_request
    get 'http://test.host/'
    assert_nil last_response.headers["Strict-Transport-Security"]
  end
end


