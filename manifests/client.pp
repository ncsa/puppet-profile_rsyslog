# @summary Configures an rsyslog client
#
# Configures an rsyslog client for NCSA systems
#
# @example
#   include profile_rsyslog::client
#
# @see https://forge.puppet.com/puppet/rsyslog
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
# @param config_modules
#   A hash of hashes to provide rsyslog module configuration options
#
# @param config_rulesets
#   A hash of hashes to provide rsyslog ruleset configuration options
#
# @param feature_packages
#   An array of extra "feature" packages to install for rsyslog.
#
# @param override_default_config
#   Override the content of the default config file or not?
#
# @param purge_config_files
#   Purge other config file from the include dir (/etc/rsyslog.d/) or not.
class profile_rsyslog::client (
  Hash    $config_actions,
  Hash    $config_custom,
  Hash    $config_global,
  Hash    $config_modules,
  Hash    $config_rulesets,
  Array   $feature_packages,
  Boolean $override_default_config,
  Boolean $purge_config_files,
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
    modules       => $config_modules,
    rulesets      => $config_rulesets,
  }
}
