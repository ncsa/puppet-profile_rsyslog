# profile_rsyslog
 
Configures rsyslog client or relay for NCSA
 
## Dependencies
- [puppet/rsyslog](https://forge.puppet.com/puppet/rsyslog)
- [puppetlabs/stdlib](https://forge.puppet.com/puppetlabs/stdlib)

 
## Reference
 
### class profile_rsyslog (
Use the relay component of this profile to setup a hosts firewall
to accept incoming logs from other rsyslog clients.
-  Hash    $config_actions,
-  Hash    $config_custom,
-  Hash    $config_global,
-  Hash    $config_inputs,
-  Hash    $config_modules,
-  Hash    $config_rulesets,
-  Hash    $config_templates,
-  Array   $feature_packages,
-  Boolean $override_default_config,
-  Boolean $purge_config_files,

### class profile_rsyslog::relay (
-  Array[String] $allow_ip_ranges
-  Hash          $firewall_port_data,

See also: [REFERENCE.md](REFERENCE.md)

# General usage
By default, this profile will configure most of rsyslog, but will not
configure any sending rulesets. This includes not sending logs
to a target host.

# Client usage

include ::profile_rsyslog

Hiera data example:
The most important setup here is the 'relay-admin-server-relp',
which tells rsyslog where to actually send logs.
```
---
profile_rsyslog::config_rulesets:
  local_messages:
    rules:
      - action:
          name: "01_all_local"
          type: "omfile"
          facility: "*.info;mail.none;authpriv.none;cron.none"
          config:
            file: "/var/log/messages"
      - action:
          name: "02_auth_logs"
          type: "omfile"
          facility: "auth,authpriv.*"
          config:
            file: "/var/log/secure"
      - action:
          name: "03_mail_logs"
          type: "omfile"
          facility: "mail.*"
          config:
            file: "/var/log/maillog"
      - action:
          name: "04_cron_logs"
          type: "omfile"
          facility: "cron.*"
          config:
            file: "/var/log/cronlog"
      - action:
          name: "05_emergency_msgs"
          type: "omusrmsg"
          facility: "*.emerg"
          config:
            users: "*"
      - action:
          name: "06_boot_logs"
          type: "omfile"
          facility: "local7.*"
          config:
            file: "/var/log/boot.log"
      - action:
          name: "relay-admin-server-relp"
          type: "omrelp"
          config:
            target: "mlong-pup.ncsa.illinois.edu"
            port: "20515"
            queue.FileName: "adm-buffer"
            queue.SaveOnShutdown: "on"
            queue.Type: "LinkedList"
            queue.size: "1000000"
            queue.maxdiskspace: "10000000000"
            queue.syncqueuefiles: "on"
            Action.ResumeInterval: "30"
            Action.ResumeRetryCount: "-1"
            timeout: "6" 
```
# Relay usage

include ::profile_rsyslog::relay

Hiera data example:
Note the different target host to send logs, and the additional
'profile_rsyslog::relay::allow_ip_ranges'. This setup will tell
the relay host to accept incoming logs from 141.142.193.171 and
then forward them to security.
```
---
profile_rsyslog::config_rulesets:
  local_messages:
    rules:
      - action:
          name: "all_local"
          type: "omfile"
          facility: "*.info;mail.none;authpriv.none;cron.none"
          config:
            file: "/var/log/messages"
      - action:
          name: "auth_logs"
          type: "omfile"
          facility: "auth,authpriv.*"
          config:
            file: "/var/log/secure"
      - action:
          name: "mail_logs"
          type: "omfile"
          facility: "mail.*"
          config:
            file: "/var/log/maillog"
      - action:
          name: "cron_logs"
          type: "omfile"
          facility: "cron.*"
          config:
            file: "/var/log/cronlog"
      - action:
          name: "emergency_msgs"
          type: "omusrmsg"
          facility: "*.emerg"
          config:
            users: "*"
      - action:
          name: "boot_logs"
          type: "omfile"
          facility: "local7.*"
          config:
            file: "/var/log/boot.log"
      - action:
          name: "ncsa-security-relp"
          type: "omrelp"
          config:
            target: "syslog.security.ncsa.illinois.edu"
            port: "1514"
            queue.FileName: "syslog-security-buffer"
            queue.SaveOnShutdown: "on"
            queue.Type: "LinkedList"
            queue.size: "1000000"
            queue.maxdiskspace: "10000000000"
            queue.syncqueuefiles: "on"
            Action.ResumeInterval: "30"
            Action.ResumeRetryCount: "-1"
            timeout: "6"
profile_rsyslog::relay::allow_ip_ranges:
  - "141.142.193.171"
```
