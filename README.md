# ipa Puppet module
[![Build Status](https://travis-ci.org/Puppet-Finland/puppet-ipa.svg?branch=master)](https://travis-ci.org/Puppet-Finland/puppet-ipa)

## Overview

This module will install and configure IPA servers, replicas, and clients. This module was forked from huit-ipa,
and refactored with a focus on simplicity and ease of use.

## Usage

### Example usage:

```puppet
class { 'ipa':
    ipa_role                    => 'master',
    domain                      => 'vagrant.example.lan',
    ipa_server_fqdn             => 'ipa-server-1.vagrant.example.lan',
    admin_password              => 'vagrant123',
    directory_services_password => 'vagrant123',
    ip_address                  => '192.168.56.35',
    enable_ip_address           => true,
    enable_hostname             => true,
}
```

Adding a replica:

```puppet
class { 'ipa':
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

Adding a client:

```puppet
class { 'ipa':
ipa_role             => 'client',
domain               => 'vagrant.example.lan',
domain_join_password => 'vagrant123',
ipa_master_fqdn      => 'ipa-server-1.vagrant.example.lan',
}
```
