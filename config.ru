require "rubygems"
require "geminabox"
require 'net-ldap'

Geminabox.allow_replace = !!ENV['ALLOW_REPLACE']
Geminabox.data = '/webapps/geminabox/data'
Geminabox.build_legacy = false

$username = ENV['USERNAME']
$password = ENV['PASSWORD']

$ldap_host = ENV['LDAP_HOST']
$ldap_port = ENV['LDAP_PORT']
# can be start_tls, simple_tls
$ldap_encryption = ENV['LDAP_ENCRYPTION'] || 'start_tls'
$ldap_base = ENV['LDAP_BASE']
$ldap_user_id = ENV['LDAP_USER_ID'] || 'uid'
$ldap_filter = ENV['LDAP_FILTER']

if $username && $password
  puts "using Basic-Auth configuration"
  ## BASIC AUTH
  Geminabox::Server.helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Geminabox")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [$username, $password]
    end
  end

  Geminabox::Server.before '/upload' do
    protected!
  end

  Geminabox::Server.before do
    protected! if request.delete? || ENV['PRIVATE'].to_s == 'true'
  end

  Geminabox::Server.before '/api/v1/gems' do
    unless env['HTTP_AUTHORIZATION'] == 'API_KEY'
      halt 401, "Access Denied. Api_key invalid or missing.\n"
    end
  end
elsif $ldap_host && $ldap_port && $ldap_encryption && $ldap_base && $ldap_user_id
  puts "using LDAP-configuration"
  ## LDAP
  class Geminabox::Server
    helpers do
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="LDAP HTTP Auth")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        logged_in = false
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        if @auth.provided? && @auth.basic?
          ldap = Net::LDAP.new(
              host: $ldap_host,
              port: $ldap_port,
              encryption: $ldap_encryption.to_sym
          )
          # add the configured extra filter on ldap like groups
          extra_filter = ''
          if $ldap_filter
            extra_filter = " (#{$ldap_filter})"
          end
          $filter = "(& (#{$ldap_user_id}=#{@auth.credentials[0]})#{extra_filter})"
          # now contstruct the filter with the user id matching and the extra filter
          $filter = Net::LDAP::Filter.from_rfc2254($filter)
          logged_in = ldap.bind_as(
              base: $ldap_base,
              filter: $filter,
              password: @auth.credentials[1]
          )
        end
        logged_in
      end
    end
    before do
      if request.path_info == "/upload"
        protected!
      end
      if request.request_method == 'DELETE'
        protected!
      end
      if request.request_method == 'POST'
        if request.path_info == "/upload"
          protected!
        end
      end
    end
  end
else
  puts "using No-Authentication"
end

run Geminabox::Server