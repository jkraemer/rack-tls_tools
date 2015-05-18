require 'minitest_helper'

class TlsToolsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rack::TlsTools::VERSION
  end
end
