require 'minitest_helper'

class HpkpTest < Minitest::Test
  def setup
    mock_app Rack::TlsTools::Hpkp, hosts: [
      {
        names: %w(test.host www.test.host),
        sha256: %w(TjqopKw/ZnhQVuSJcigTYFZzyzcV4meL4ukoThbkr0E= IXx7fkhrahUAGPqxiGyXvQ0aACvZiT0GqELG5X+Irlc=)
      },
      {
        names: %w(example.com),
        sha256: %w(cw67ZLBJG8VBdPwhnpAWV9hn65+ETjdJ80N7QaKPq4Q= /OO9h4ETSyxhCj11N+52iPXCkZY1hoWSye9Xb3AkbZ0=),
        subdomains: true,
        report_uri: 'https://report.here/',
        max_age: 30000,
      },
    ]
  end

  def test_should_not_change_http_requests
    get 'http://example.com/'
    assert_nil last_response.headers["Public-Key-Pins"]
  end

  def test_should_not_change_requests_to_other_hosts
    get 'https://foo.com/'
    assert_nil last_response.headers["Public-Key-Pins"]
  end

  def test_should_add_header
    get 'https://www.test.host/'
    assert_equal %{pin-sha256="TjqopKw/ZnhQVuSJcigTYFZzyzcV4meL4ukoThbkr0E="; pin-sha256="IXx7fkhrahUAGPqxiGyXvQ0aACvZiT0GqELG5X+Irlc="; max-age=#{Rack::TlsTools::Hpkp::DEFAULT_MAX_AGE}}, last_response.headers["Public-Key-Pins"]
  end

  def test_should_add_header_with_options
    get 'https://example.com/'
    assert_equal %{pin-sha256="cw67ZLBJG8VBdPwhnpAWV9hn65+ETjdJ80N7QaKPq4Q="; pin-sha256="/OO9h4ETSyxhCj11N+52iPXCkZY1hoWSye9Xb3AkbZ0="; max-age=30000; includeSubDomains; report-uri="https://report.here/"}, last_response.headers["Public-Key-Pins"]
  end

end

