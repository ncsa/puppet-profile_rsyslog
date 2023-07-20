# @summary Configures an NCSA rsyslog collector
#
# This class configures an NCSA rsyslog collector to facilitate
# sending logs to security from machines that are in isolated networks
#
# @example
#   include profile_rsyslog::collector
#
# @see https://forge.puppet.com/puppet/rsyslog
#
# @param allow_ip_ranges
#   An array of CIDR ranges from which to accept incoming logs.
#
# @param days_to_retain
#   Integer of number of days worth of logs to retain locally.
#
# @param firewall_port_data
#   A hash of hashes to provide input on ports to open in the firewall.
#
# @param log_dir
#   String of local directory where collected logs are stored
#   This directory also needs to match those included in the:
#     $logrotate_config
#     $profile_rsyslog::config_templates
#
# @param logrotate_bin
#   String of full path to logrotate binary file
#
# @param logrotate_config_content
#   String of file content for the logrotate config to rotate copy of rotated logs
#
# @param logrotate_config_path
#   String of fule path to the logrotate config to rotate copy of rotated logs
#
# @param logrotate_cron_hour
#   String of the hour that the logrotate cron should run for collector logs
#
# @param logrotate_cron_minute
#   String of the minute that the logrotate cron should run for collector logs
#
# @param logrotate_cron_month
#   String of the month that the logrotate cron should run for collector logs
#
# @param logrotate_cron_monthday
#   String of the monthday that the logrotate cron should run for collector logs
#
# @param logrotate_cron_weekday
#   String of the weekday that the logrotate cron should run for collector logs
#
# @param prereq_packages
#   Array of prerequisite packages that need to be installed for rsyslog collectors
#
class profile_rsyslog::collector (
  Array[String] $allow_ip_ranges,
  Integer       $days_to_retain,
  Hash          $firewall_port_data,
  String        $log_dir,
  String        $logrotate_bin,
  String        $logrotate_config_content,
  String        $logrotate_config_path,
  String        $logrotate_cron_hour,
  String        $logrotate_cron_minute,
  String        $logrotate_cron_month,
  String        $logrotate_cron_monthday,
  String        $logrotate_cron_weekday,
  Array         $prereq_packages,
) {
  ensure_packages( $prereq_packages )

  # Allow rsyslog forwarding
  $allow_ip_ranges.each | $ip_range | {
    $firewall_port_data.each | $name, $data | {
      $port     = $data[port]
      $protocol = $data[protocol]
      firewall { "500 profile_rsyslog::collector - allow rsyslog ${name} from ${ip_range}":
        proto  => $protocol,
        dport  => $port,
        action => 'accept',
        source => $ip_range,
      }
    }
  }

  # Setup local log directory for forwarded logs
  file { $log_dir:
    ensure => 'directory',
  }

  file { $logrotate_config_path:
    content => $logrotate_config_content,
  }

  cron { 'COLLECTOR LOG ROTATION':
    command  => "${logrotate_bin} -f ${logrotate_config_path}",
    user     => 'root',
    hour     => $logrotate_cron_hour,
    minute   => $logrotate_cron_minute,
    weekday  => $logrotate_cron_weekday,
    month    => $logrotate_cron_month,
    monthday => $logrotate_cron_monthday,
  }

  cron { 'COLLECTOR LOG CLEAN OLD FILES':
    command => "find ${log_dir} -mtime +${days_to_retain} -type f -delete",
    user    => 'root',
    special => 'daily',
  }

  cron { 'COLLECTOR LOG CLEAN EMPTY DIRECTORIES':
    command => "find ${log_dir} -empty -type d -delete",
    user    => 'root',
    special => 'daily',
  }

  if ( lookup('profile_backup::client::enabled') ) {
    include profile_backup::client

    profile_backup::client::add_job { 'rsyslog_collector':
      paths            => $log_dir,
    }
  }
}
