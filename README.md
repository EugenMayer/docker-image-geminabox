# Geminabox rubygems server

Based on alpine / [geminabox](https://github.com/geminabox/geminabox), providing a configurable Docker supporting
 - no auth
 - basic auth
 - LDAP auth

## Environment based configuration
See `tests/<authmethod>` for examples
### Basic auth
 - USERNAME: 'admin'
 - PASSWORD: 'secret'
 - PRIVATE: 1 `// is true, also getting gems is protected`

### LDAP auth
 - LDAP_HOST: 'your.ldapserver.tld'
 - LDAP_PORT: 389
 - LDAP_ENCRYPTION: 'start_tls' `// [start_tls|simple_tls]`
 - LDAP_BASE: 'ou=employees,dc=company,dc=com'
 - LDAP_USER_ID: 'uid'


# Credits
First of all to [geminabox](https://github.com/geminabox/geminabox)
Credits to [TigerWolf](https://github.com/TigerWolf/geminabox) and [yuri-karpovich](https://github.com/yuri-karpovich/geminabox)