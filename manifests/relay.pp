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
# @param firewall_port_data
#   A hash of hashes to provide input on ports to open in the firewall.
#
class profile_rsyslog::relay (
  Array[String] $allow_ip_ranges,
  Hash          $firewall_port_data,
) {

  # Allow rsyslog forwarding
  $allow_ip_ranges.each | $ip_range | {
    $firewall_port_data.each | $name, $data | {
      $port     = $data[port]
      $protocol = $data[protocol]
      firewall { "500 profile_rsyslog::relay - allow rsyslog ${name} from ${ip_range}":
        proto  => $protocol,
        dport  => $port,
        action => 'accept',
        source => $ip_range,
      }
    }
  }

}
