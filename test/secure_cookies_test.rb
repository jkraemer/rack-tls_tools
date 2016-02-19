require 'minitest_helper'

class SecureCookiesTest < Minitest::Test
  def setup
    mock_app Rack::TlsTools::SecureCookies, hosts: %w(foo.com)
  end

  def test_should_not_change_other_hosts_requests
    get 'https://example.com/'
    assert_equal "foo=bar; path=/; secure; HttpOnly\nx=y; path=/\na=b; secure", last_response.headers["Set-Cookie"]
  end

  def test_should_not_change_http_requests
    get 'http://foo.com/'
    assert_equal "foo=bar; path=/; secure; HttpOnly\nx=y; path=/\na=b; secure", last_response.headers["Set-Cookie"]
  end

  def test_should_secure_insecure_cookies
    get 'https://foo.com/'
    assert_equal "foo=bar; path=/; secure; HttpOnly\nx=y; path=/; secure\na=b; secure", last_response.headers["Set-Cookie"]
  end

end


