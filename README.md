# Geminabox rubygems server

A docker image to serve you as a rubygems server.

Based on alpine / [geminabox](https://github.com/geminabox/geminabox), providing a configurable Docker supporting
 - no auth
 - basic auth (for admin and optional for the reader)
 - LDAP auth (admin/reader is the same)

## Environment based configuration
See `tests/<authmethod>` for examples
### Basic auth
 - ADMINUSERNAME: 'adminuser'
 - ADMINPASSWORD: 'adminpw'
 - READERUSERNAME: 'readeruser'
 - READERPASSWORD: 'readerpw'
 - READ_AUTH: 1 `// if set, also getting gems is protected`

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