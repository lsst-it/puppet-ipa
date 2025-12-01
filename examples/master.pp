require epel  # provides kstart package on el
require cron  # master/replica needs cron to be installed

Yumrepo <||>
-> class { 'ipa':
  ipa_role                    => 'master',
  domain                      => 'example.com',
  admin_password              => 'rspecrspec123',
  directory_services_password => 'rspecrspec123',
  idstart                     => 70000,
  configure_dns_server        => false,
  configure_ntp               => false,  # chronyd usually fails under gha
}
