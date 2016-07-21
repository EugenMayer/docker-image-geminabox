# Geminabox rubygems server

A docker image to serve you as a rubygems server.

Based on alpine / [geminabox](https://github.com/geminabox/geminabox), providing a configurable Docker supporting
 - no auth
 - basic auth
 - LDAP auth

## Environment based configuration
See `tests/<authmethod>` for examples
### Basic auth
 - USERNAME: 'admin'
 - PASSWORD: 'secret'
 - PRIVATE: 1 `// if true, also getting gems is protected`

### LDAP auth
 - LDAP_HOST: 'your.ldapserver.tld'
 - LDAP_PORT: 389
 - LDAP_ENCRYPTION: 'start_tls' `// [start_tls|simple_tls]`
 - LDAP_BASE: 'ou=employees,dc=company,dc=com'
 - LDAP_USER_ID: 'uid'

# Contributions
You are very welcome to open issues or pull-requests to contribute! Thanks

# Credits
First of all to [geminabox](https://github.com/geminabox/geminabox) and also to [TigerWolf](https://github.com/TigerWolf/geminabox) and [yuri-karpovich](https://github.com/yuri-karpovich/geminabox)