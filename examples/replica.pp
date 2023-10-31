require epel  # provides kstart package on el
require cron  # master/replica needs cron to be installed

Yumrepo <||>
-> class { 'ipa':
  ipa_role             => 'replica',
  domain               => 'example.com',
  ipa_master_fqdn      => 'master.example.com',
  admin_password       => 'rspecrspec123',
  configure_dns_server => false,
  configure_ntp        => false,
  configure_replica_ca => true,
}
