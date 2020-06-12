# profile_rsyslog
 
Configures rsyslog client or relay for NCSA
 
## Dependencies
- [puppet/rsyslog](https://forge.puppet.com/puppet/rsyslog)
- [puppetlabs/stdlib](https://forge.puppet.com/puppetlabs/stdlib)

 
## Reference
 
### class profile_rsyslog::relay (
-  Hash                       $config_global,
-  Hash                       $config_modules,
-  Hash                       $config_actions,
-  Hash                       $config_inputs,
-  String                     $relay_port,
-  Array[Stdlib::IP::Address] $relayed_hosts,
  
### class profile_rsyslog::client (
-  Hash $config_global,
-  Hash $config_modules,
-  Hash $config_actions,

See also: [REFERENCE.md](REFERENCE.md)