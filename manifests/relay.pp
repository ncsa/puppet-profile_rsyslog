# @summary Configures an NCSA rsyslog relay
#
# RELAY FUNCTIONALITY IS A WIP
# USE CAUTION IF DEPLOYING TO PRODUCTION
#
# This class configures an NCSA rsyslog relay to facilitate
# sending logs to security from machines that are in isolated networks
#
# @example
#   include profile_rsyslog::relay
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
class profile_rsyslog::relay (
  Array[String] $allow_ip_ranges,
  Hash          $config_inputs,
  Hash          $config_templates,
  Hash          $firewall_port_data,
) {

  class { 'relay':
    inputs        => $config_inputs,
    templates     => $config_templates,
  }

  # Allow rsyslog forwarding
  $allow_ip_ranges.each | $ip_range | {
    $firewall_port_data.each | $name, $data | {
      $port     = $data[port]
      $protocol = $data[protocol]
      firewall { "500 profile_rsyslog::relay - allow rsyslog ${name} from ${ip_range}":
        proto  => $protocol,
        dport  => $port,
        action => 'accept',
        source => "${ip_range}",
      }
    }
  }

}
