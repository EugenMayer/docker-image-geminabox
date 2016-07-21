require "rubygems"
require "geminabox"
require 'net-ldap'

Geminabox.data = '/geminabox/data'
Geminabox.build_legacy = false

$admin_user = ENV['ADMINUSERNAME']
$admin_password = ENV['ADMINPASSWORD']
$reader_user = ENV['READERUSERNAME']
$reader_password = ENV['READERPASSWORD']
$read_auth =  false
$read_auth = true if ENV['READ_AUTH']
$ldap_host = ENV['LDAP_HOST']
$ldap_port = ENV['LDAP_PORT']
# can be start_tls, simple_tls
$ldap_encryption = ENV['LDAP_ENCRYPTION'] || 'start_tls'
$ldap_base = ENV['LDAP_BASE']
$ldap_user_id = ENV['LDAP_USER_ID'] || 'uid'
$ldap_filter = ENV['LDAP_FILTER']

################ BASIC AUTH
if $admin_user && $admin_password
  puts "using Basic-Auth configuration"
  puts "enabling read protection" if $read_auth
  ## BASIC AUTH
  Geminabox::Server.helpers do
    def admin_protected!
      unless admin_authorized?
        response['WWW-Authenticate'] = %(Basic realm="Geminabox")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def admin_authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [$admin_user, $admin_password]
    end

    def reader_protected!
      if !admin_authorized? && !reader_authorized?
        response['WWW-Authenticate'] = %(Basic realm="Geminabox")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def reader_authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [$reader_user, $reader_password]
    end
  end
################ LDAP AUTH
elsif $ldap_host && $ldap_port && $ldap_encryption && $ldap_base && $ldap_user_id
  puts "using LDAP-configuration"
  ## LDAP
  Geminabox::Server.helpers do
    def admin_protected!
      unless admin_authorized?
        response['WWW-Authenticate'] = %(Basic realm="LDAP HTTP Auth")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def reader_protected!
      unless admin_authorized?
        response['WWW-Authenticate'] = %(Basic realm="Geminabox")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def admin_authorized?
      logged_in = false
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
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
            admin_password: @auth.credentials[1]
        )
      end
      logged_in
    end
  end
################ NO AUTH
else
  puts "using No-Authentication"

  Geminabox::Server.helpers do
    def admin_protected!
      return true
    end

    def reader_protected!
      return true
    end
  end
end

Geminabox::Server.before '/upload' do
  admin_protected!
end

Geminabox::Server.before do
  if request.delete?
    admin_protected!
  elsif $read_auth
    reader_protected!
  end
end

Geminabox::Server.before '/api/v1/gems' do
  unless env['HTTP_AUTHORIZATION'] == 'API_KEY'
    halt 401, "Access Denied. Api_key invalid or missing.\n"
  end
end

run Geminabox::Server