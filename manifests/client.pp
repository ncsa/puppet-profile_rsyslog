# @summary Configures an rsyslog client
#
# Configures and rsyslog client for NCSA systems
#
# @example
#   include profile_rsyslog::client
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
class profile_rsyslog::client (
  Hash $config_global,
  Hash $config_modules,
  Hash $config_actions,
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
  }
}
