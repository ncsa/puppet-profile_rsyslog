# profile_rsyslog

[![pdk-validate](https://github.com/ncsa/puppet-profile_rsyslog/actions/workflows/pdk-validate.yml/badge.svg)](https://github.com/ncsa/puppet-profile_rsyslog/actions/workflows/pdk-validate.yml)
[![yamllint](https://github.com/ncsa/puppet-profile_rsyslog/actions/workflows/yamllint.yml/badge.svg)](https://github.com/ncsa/puppet-profile_rsyslog/actions/workflows/yamllint.yml)

NCSA Common Puppet Profiles - configure rsyslog client or collector for NCSA

## Description

This common puppet profile module configures standard syslog client or 
collector as used by NCSA. It configures rsyslog.

It supports the concept of setting up an optional syslog collector. The 
idea being that the collector log host may be cluster specific, which then 
forwards along to a centralized log host.


## Dependencies
- [puppet/rsyslog](https://forge.puppet.com/puppet/rsyslog)
- [puppetlabs/stdlib](https://forge.puppet.com/puppetlabs/stdlib)

 
## Reference

[REFERENCE.md](REFERENCE.md)


## Usage

### General usage

By default, this profile will configure most of rsyslog, but will not
configure any sending rulesets. This includes not sending logs to a 
target host.

### Client usage

```
include ::profile_rsyslog
```

#### Hiera data example

The most important setup here is the `forward-to-log-collector-server-relp`,
which tells rsyslog where to actually send logs.

```
---
profile_rsyslog::config_rulesets:
  localhost_messages:
    rules:
      - action:
          name: "01_all_generic_message_logs"
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
            file: "/var/log/cron"
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
          name: "forward-to-log-collector-server-relp"
          type: "omrelp"
          config:
            target: "syslog.security.ncsa.illinois.edu"
            port: "1514"
            queue.FileName: "forward-to-log-collector-server-buffer"
            queue.SaveOnShutdown: "on"
            queue.Type: "LinkedList"
            queue.size: "1000000"
            queue.maxdiskspace: "10000000000"
            queue.syncqueuefiles: "on"
            Action.ResumeInterval: "30"
            Action.ResumeRetryCount: "-1"
            timeout: "6" 
```

### Collector usage

```
include ::profile_rsyslog::collector
```

### Hiera data example

Note several differences:
* different target host to send logs
* additional `profile_rsyslog::config_rulesets` for both `localhost_messages` 
and `collected_messages`
* additional `profile_rsyslog::config_templates` for keeping local copy of 
collected logs
* additional `profile_rsyslog::collector::allow_ip_ranges`. This setup will tell
the collector host to accept incoming logs from 172.0.0.0/24 and
then forward them to a central log host.

```
---
profile_rsyslog::config_inputs:
  imtcp:
    type: "imtcp"
    config:
      port: 514
      Ruleset: "collected_messages"
  imudp:
    type: "imudp"
    config:
      port: 514
      Ruleset: "collected_messages"
  imrelp:
    type: "imrelp"
    config:
      port: 20515
      Ruleset: "collected_messages"
profile_rsyslog::config_rulesets:
  localhost_messages:
    rules:
      - action:
          name: "01_all_generic_message_logs"
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
            file: "/var/log/cron"
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
          name: "all_localhost_logs"
          type: "omfile"
          facility: "*.*"
          config:
            dynaFile: "localhost_syslog"
      - action:
          name: "forward-localhost-to-log-collector-server-relp"
          type: "omrelp"
          config:
            target: "syslog.security.ncsa.illinois.edu"
            port: "1514"
            queue.FileName: "forward-localhost-to-log-collector-server-buffer"
            queue.SaveOnShutdown: "on"
            queue.Type: "LinkedList"
            queue.size: "1000000"
            queue.maxdiskspace: "10000000000"
            queue.syncqueuefiles: "on"
            Action.ResumeInterval: "30"
            Action.ResumeRetryCount: "-1"
            timeout: "6"
  collected_messages:
    rules:
      - action:
          name: "all_collected"
          type: "omfile"
          facility: "*.*"
          config:
            dynaFile: "collected_syslog"
      - action:
          name: "forward-collected-to-log-collector-server-relp"
          type: "omrelp"
          config:
            target: "syslog.security.ncsa.illinois.edu"
            port: "1514"
            queue.FileName: "forward-collected-to-log-collector-server-buffer"
            queue.SaveOnShutdown: "on"
            queue.Type: "LinkedList"
            queue.size: "1000000"
            queue.maxdiskspace: "10000000000"
            queue.syncqueuefiles: "on"
            Action.ResumeInterval: "30"
            Action.ResumeRetryCount: "-1"
            timeout: "6"
profile_rsyslog::config_templates:
  localhost_syslog:
    type: "string"
    string: "/var/log/loghost/%$myhostname%/syslog.log"
  collected_syslog:
    type: "string"
    string: "/var/log/loghost/%HOSTNAME%/syslog.log"
profile_rsyslog::collector::allow_ip_ranges:
  - "172.0.0.0/24"
```

