module Rack
  module TlsTools

    # https://developer.mozilla.org/en-US/docs/Web/Security/Public_Key_Pinning
    class Hpkp

      # three months
      DEFAULT_MAX_AGE = 3600 * 24 * 60

      def initialize(app, options = {})
        @app = app
        @options = {
          enable: true,
          max_age: DEFAULT_MAX_AGE,
          subdomains: false,
          hosts: [],
        }.merge(options)
        @config_by_hostname = flatten_host_config @options[:hosts]
      end

      def call(env)
        @app.call(env).tap do |response|
          @request = Rack::Request.new env
          if @request.ssl? and config = @config_by_hostname[@request.host] and config[:enable]
            add_hpkp_header! response[1], config
          end
        end
      end

      private

      def add_hpkp_header!(headers, config)
        val = config[:sha256].map{|h|%{pin-sha256="#{h}"}}.join('; ')
        val << %{; max-age=#{config[:max_age]}}         if config[:max_age]
        val << %{; includeSubDomains}                   if config[:subdomains]
        val << %{; report-uri="#{config[:report_uri]}"} if config[:report_uri]
        headers['Public-Key-Pins'] = val
      end

      def flatten_host_config(hosts)
        {}.tap do |config_by_hostname|
          hosts.each do |host_config|
            host_config[:names].each do |hostname|
              cfg = @options.merge host_config
              cfg.delete :names
              cfg.delete :hosts
              config_by_hostname[hostname] = cfg
            end
          end
        end
      end
    end
  end
end

