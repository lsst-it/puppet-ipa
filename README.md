# easy_ipa Puppet module
[![Build Status](https://travis-ci.org/Puppet-Finland/puppet-ipa.svg?branch=master)](https://travis-ci.org/Puppet-Finland/puppet-ipa)

## Overview

This module will install and configure IPA servers, replicas, and clients. This module was forked from huit-ipa,
and refactored with a focus on simplicity and ease of use.

## Usage

### Example usage:

Creating an IPA master, with the WebUI proxied to `https://localhost:8440`.
```puppet
class {'easy_ipa':
    ipa_role                    => 'master',
    domain                      => 'vagrant.example.lan',
    ipa_server_fqdn             => 'ipa-server-1.vagrant.example.lan',
    admin_password              => 'vagrant123',
    directory_services_password => 'vagrant123',
    ip_address                  => '192.168.56.35',
    enable_ip_address           => true,
    enable_hostname             => true,
    webui_enable_proxy          => true,
}
```

Adding a replica:
```puppet
class {'::easy_ipa':
    ipa_role             => 'replica',
    domain               => 'vagrant.example.lan',
    ipa_server_fqdn      => 'ipa-server-2.vagrant.example.lan',
    domain_join_password => 'vagrant123',
    ip_address           => '192.168.56.36',
    enable_ip_address    => true,
    enable_hostname      => true,
    ipa_master_fqdn      => 'ipa-server-1.vagrant.example.lan',
}
```

Add iptables/ip6tables allow rules:

```
class { '::easy_ipa::packetfilter::server':
    allow_address_ipv4 => '10.0.0.0/8',
    allow_address_ipv6 => '::1',
}
```

Add a backup job to cron:
```
    easy_ipa::backup { 'full':
      type      => 'full',
      timestamp => false,
      monthday  => 1,
      weekday   => undef,
      hour      => 4,
      minute    => 15,
      email     => 'admin@domain.com',
    }
```
Backup type can be 'full' or 'data'. Timestamp is either true (default) or
false. A wrapper script is used as ipa-backup always adds a timestamp to the
backup directory, which makes no sense if an external system (e.g. Bacula) is
handling backup versioning anyways.


Adding a client:
```puppet
class {'::easy_ipa':
ipa_role             => 'client',
domain               => 'vagrant.example.lan',
domain_join_password => 'vagrant123',
ipa_master_fqdn      => 'ipa-server-1.vagrant.example.lan',
}
```
