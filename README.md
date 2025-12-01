# ipa

## Overview

This module manages [FreeIPA](https://www.freeipa.org/) servers, replicas, and clients.

This module was forked from [Puppet-Finland/puppet-ipa](https://github.com/Puppet-Finland/puppet-ipa),
which was forked from [jpuskar/puppet-ipa](https://github.com/jpuskar/puppet-ipa),
which was forked from [huit/puppet-ipa](https://github.com/huit/puppet-ipa).

## Usage

### Example usage:

```puppet
class { 'ipa':
  ipa_role                    => 'master',
  domain                      => 'example.com',
  admin_password              => 'rspecrspec123',
  directory_services_password => 'rspecrspec123',
  idstart                     => 70000,
  configure_dns_server        => false,
  configure_ntp               => false,
}
```

Adding a replica:

```puppet
class { 'ipa':
  ipa_role             => 'replica',
  domain               => 'example.com',
  ipa_master_fqdn      => 'master-puppet8.example.com',
  admin_password       => 'rspecrspec123',
  configure_dns_server => false,
  configure_ntp        => false,
  configure_replica_ca => true,
}
```

Adding a client:

```puppet
class { 'ipa':
  ipa_role              => 'client',
  domain                => 'example.com',
  domain_join_principal => 'admin',
  domain_join_password  => 'rspecrspec123',
  ipa_master_fqdn       => 'master-puppet8.example.com',
  configure_ntp         => false,
}
```
