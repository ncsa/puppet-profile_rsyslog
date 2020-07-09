# @summary Configures and NCSA rsyslog relay
#
# This class configures an NCSA rsyslog relay to facilitate
# sending logs to security from machines that are in isolated networks
#
# @example
#   include profile_rsyslog::relay
#
# @see https://forge.puppet.com/puppet/rsyslog
#
# @param config_global
#   A hash of hashes to provide global configuration options
#
# @param config_modules
#   A hash of hashes to provide rsyslog module configuration options
#
# @param config_actions
#   A hash of hashes to provide rsyslog actions configuration options
#
# @param config_rulesets
#   A hash of hashes to provide rsyslog rulesets configuration options
#
# @param config_templates
#   A hash of hashes to provide rsyslog templates configuration options
#
# @param config_custom
#   A hash of hashes to provide rsyslog objects that require custom configuration snips
#
# @param config_inputs
#   A hash of hashes to provide rsyslog inputs configuration options
#
# @param relayed_hosts
#   An array of subnets or hosts allowed to relay logs via this server
#   Format can be a single IP or CIDR subnet
#
# @param relay_port
#   The port number that will be used to listen for connections for relayed syslog
#
class profile_rsyslog::relay (
  Hash                       $config_global,
  Hash                       $config_modules,
  Hash                       $config_actions,
  Hash                       $config_templates,
  Hash                       $config_rulesets,
  Hash                       $config_custom,
  Hash                       $config_inputs,
  String                     $relay_port,
  Array[Stdlib::IP::Address] $relayed_hosts,
) {

  class { 'rsyslog':
    feature_packages        => ['rsyslog-relp'],
    purge_config_files      => true,
    override_default_config => true,
  }

  class { 'rsyslog::config':
    global_config => $config_global,
    modules       => $config_modules,
    actions       => $config_actions,
    inputs        => $config_inputs,
    templates     => $config_templates,
    rulesets      => $config_rulesets,
    custom_config => $config_custom,
  }

  # Allow rsyslog forwarding
  $relayed_hosts.each | String $host | {
    firewall { "500 profile_rsyslog::relay - rsyslog from ${host}":
      proto  => 'tcp',
      dport  => $relay_port,
      action => 'accept',
      source => $host,
    }
  }
}
