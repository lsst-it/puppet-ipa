require epel  # provides kstart package on el

Yumrepo <||>
-> class { 'ipa':
  ipa_role              => 'client',
  domain                => 'example.com',
  domain_join_principal => 'admin',
  domain_join_password  => 'rspecrspec123',
  ipa_master_fqdn       => 'master.example.com',
  configure_ntp         => false,  # chronyd usually fails under gha
}
