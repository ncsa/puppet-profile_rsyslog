# @summary Configures an NCSA rsyslog relay
#
# This class configures an NCSA rsyslog relay to facilitate
# sending logs to security from machines that are in isolated networks
#
# @example
#   include profile::rsyslog::relay
#
# @see https://forge.puppet.com/puppet/rsyslog
#
# @param allow_ip_ranges,
#   An array of CIDR ranges from which to accept incoming logs.
#
# @param config_actions
#   A hash of hashes to provide rsyslog actions configuration options
#
# @param config_custom
#   A hash of hashes to provide rsyslog objects that require custom configuration snips
#
# @param config_global
#   A hash of hashes to provide global configuration options
#
# @param config_inputs
#   A hash of hashes to provide rsyslog inputs configuration options
#
# @param config_modules
#   A hash of hashes to provide rsyslog module configuration options
#
# @param config_rulesets
#   A hash of hashes to provide rsyslog rulesets configuration options
#
# @param config_templates
#   A hash of hashes to provide rsyslog templates configuration options
#
# @param feature_packages
#   An array of extra "feature" packages to install for rsyslog.
#
# @param firewall_port_data
#   A hash of hashes to provide input on ports to open in the firewall.
#
# @param override_default_config
#   Override the content of the default config file or not?
#
# @param purge_config_files
#   Purge other config file from the include dir (/etc/rsyslog.d/) or not.
#
class profile::rsyslog::relay (
  Array[String] $allow_ip_ranges,
  Hash          $config_actions,
  Hash          $config_custom,
  Hash          $config_global,
  Hash          $config_inputs,
  Hash          $config_modules,
  Hash          $config_rulesets,
  Hash          $config_templates,
  Array         $feature_packages,
  Boolean       $override_default_config,
  Boolean       $purge_config_files,
  Hash          $firewall_port_data,
) {

  class { 'rsyslog':
    feature_packages        => $feature_packages,
    override_default_config => $override_default_config,
    purge_config_files      => $purge_config_files,
  }

  class { 'rsyslog::config':
    actions       => $config_actions,
    custom_config => $config_custom,
    global_config => $config_global,
    inputs        => $config_inputs,
    modules       => $config_modules,
    rulesets      => $config_rulesets,
    templates     => $config_templates,
  }

  # Allow rsyslog forwarding
  $allow_ip_ranges.each | $ip_range | {
    $firewall_port_data.each | $name, $data | {
      $port     = $data[port]
      $protocol = $data[protocol]
      firewall { "500 profile::rsyslog::relay - allow rsyslog ${name} from ${ip_range}":
        proto  => $protocol,
        dport  => $port,
        action => 'accept',
        source => "${ip_range}",
      }
    }
  }

}
