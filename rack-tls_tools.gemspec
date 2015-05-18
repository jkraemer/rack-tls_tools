# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/tls_tools/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-tls_tools"
  spec.version       = Rack::TlsTools::VERSION
  spec.authors       = ["Jens Kraemer"]
  spec.email         = ["jk@jkraemer.net"]

  spec.summary       = %q{Secure cookies, HSTS and HPKP for any Rack app}
  spec.description   = %q{A bunch of rack middlewares to enforce secure cookies and add HSTS (Strict Transport Security) and HPKP (Public Key Pinning) headers to your Rack application.}
  spec.homepage      = "https://github.com/jkraemer/rack-tls_tools"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rack', '>= 1.4.0'
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
