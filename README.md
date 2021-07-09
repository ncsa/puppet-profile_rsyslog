# profile_rsyslog

[![pdk-validate](https://github.com/ncsa/puppet-profile_rsyslog/actions/workflows/pdk-validate.yml/badge.svg)](https://github.com/ncsa/puppet-profile_rsyslog/actions/workflows/pdk-validate.yml)
[![yamllint](https://github.com/ncsa/puppet-profile_rsyslog/actions/workflows/yamllint.yml/badge.svg)](https://github.com/ncsa/puppet-profile_rsyslog/actions/workflows/yamllint.yml)

NCSA Common Puppet Profiles - configure rsyslog client or relay for NCSA

## Description

This common puppet profile module configures standard syslog client or 
relays as used by NCSA. It configures rsyslog.

It supports the concept of setting up an optional syslog relay. The 
idea being that the relay log host may be cluster specific, which then 
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

The most important setup here is the `relay-local-server-relp`,
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
          name: "relay-local-server-relp"
          type: "omrelp"
          config:
            target: "syslog-relay.local"
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

### Relay usage

```
include ::profile_rsyslog::relay
```

### Hiera data example

Note the different target host to send logs, and the additional
`profile_rsyslog::relay::allow_ip_ranges`. This setup will tell
the relay host to accept incoming logs from 172.0.0.0/24 and
then forward them to a central log host.

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
          name: "centralized-server-relp"
          type: "omrelp"
          config:
            target: "syslog-primary.local"
            port: "1514"
            queue.FileName: "syslog-buffer"
            queue.SaveOnShutdown: "on"
            queue.Type: "LinkedList"
            queue.size: "1000000"
            queue.maxdiskspace: "10000000000"
            queue.syncqueuefiles: "on"
            Action.ResumeInterval: "30"
            Action.ResumeRetryCount: "-1"
            timeout: "6"
profile_rsyslog::relay::allow_ip_ranges:
  - "172.0.0.0/24"
```

