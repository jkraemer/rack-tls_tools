# Rack::TlsTools [![Build Status](https://travis-ci.org/jkraemer/rack-tls_tools.png?branch=master)](https://travis-ci.org/jkraemer/rack-tls_tools)

A bunch of rack middlewares to enforce secure cookies and add HSTS and HPKP
headers to your app's responses.

## Caution

By mis-using HSTS and HPKP it's very easy to lock out your clients from your
site.

Please make sure you understand what they do and how they work before trying
this out on a production site. While experimenting it might be a good idea to
use short `max_age` values so any effects of a possible mis-configuration don't
last until next year.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-tls_tools'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-tls_tools


## Usage

### SecureCookies

To mark any cookie you set over HTTPS as *secure*, just add
`Rack::TlsTools::SecureCookies` to your middleware stack. For Rails that means
adding

```ruby
config.middleware.use Rack::TlsTools::SecureCookies
```

to your `config/application.rb`.


### HSTS

HTTP Strict Transport Security is a security feature that lets your web site
tell browsers that it should only be communicated with using HTTPS.

Basically it's a simple HTTP header sent by the server, indicating that the
current site must only be accessed over HTTPS.

- [Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/Security/HTTP_strict_transport_security)
- [RFC 6797](https://tools.ietf.org/html/rfc6797)

```ruby
config.middleware.use Rack::TlsTools::Hsts, max_age: 1.year, subdomains: false
```

### HPKP

HPKP aka Public Key Pinning is used to tell clients to associate a specific
cryptographic public key with your site. The goal is to prevent MITM attacks
with forged certificates in the future.

- [Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/Security/Public_Key_Pinning)
- [RFC7469](https://tools.ietf.org/html/rfc7469)
- [Everything you Need to Know about HTTP Public Key Pinning ](http://blog.rlove.org/2015/01/public-key-pinning-hpkp.html)

In order to add HPKP headers to your site you have to specify a set of
configurations, each consisting of a number of host names (which are all
using the same SSL certificates) and a number of hashes identifying these
certificates. So if your app serves different domains using different SSL
certificates, use a separate hash in the `hosts` array for each of them.

```ruby
config.middleware.use Rack::TlsTools::Hpkp, {
  max_age: 3.months,
  subdomains: false,
  hosts: [
    {
      names: %w(test.com www.test.com),
      sha256: %w(TjqopKw/ZnhQVuSJcigTYFZzyzcV4meL4ukoThbkr0E= IXx7fkhrahUAGPqxiGyXvQ0aACvZiT0GqELG5X+Irlc=),
      report_uri: 'https://hpkp-reports.test.com/',
    },
    {
      names: %w(example.com),
      sha256: %w(cw67ZLBJG8VBdPwhnpAWV9hn65+ETjdJ80N7QaKPq4Q= /OO9h4ETSyxhCj11N+52iPXCkZY1hoWSye9Xb3AkbZ0=),
      subdomains: true,
      max_age: 30000,
    },
  ]
}
```

The top level `max_age` and `subdomains` values serve as defaults which can be
overridden in each of the `hosts` hashes. If omitted these default to the
values shown above. `report_uri` is optional, if set, browsers should `POST`
some useful information there once they detect a certificate mismatch according
to the [RFC](https://tools.ietf.org/html/rfc7469).

**Always** add at least two hashes for each domain - one for the current key, and
one for a backup key you will be using in case the current one is lost,
compromised or simply expires.

#### Generating the relevant hashes

You can generate these hashes from your private key, your server certificate
and even the Certificate Signing Request ([Source](https://developer.mozilla.org/en-US/docs/Web/Security/Public_Key_Pinning)):

    openssl rsa -in my-key-file.key -outform der -pubout | openssl dgst -sha256 -binary | openssl enc -base64
    openssl req -in my-signing-request.csr -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
    openssl x509 -in my-certificate.crt -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/jkraemer/rack-tls_tools/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

