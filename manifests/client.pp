#
# @summary Manage ipa client
#
# @param package_name
#  The name of the package(s) to install.
#
# @param force_join
#   Force the client to join the domain even if it is already joined.
#
class easy_ipa::client (
  Array[String] $package_name = undef,
  Boolean $force_join = false,
) {
  unless $easy_ipa::final_domain_join_password {
    fail("When creating a ${easy_ipa::ipa_role} the parameter named domain_join_password cannot be empty.")
  }
  unless $easy_ipa::ipa_master_fqdn {
    fail("When creating a ${easy_ipa::ipa_role} the parameter named ipa_master_fqdn cannot be empty.")
  }

  ensure_packages($package_name)

  if $easy_ipa::mkhomedir {
    $client_install_cmd_opts_mkhomedir = '--mkhomedir'
  } else {
    $client_install_cmd_opts_mkhomedir = ''
  }

  if $easy_ipa::fixed_primary {
    $client_install_cmd_opts_fixed_primary = '--fixed-primary'
  } else {
    $client_install_cmd_opts_fixed_primary = ''
  }

  if $easy_ipa::configure_ntp {
    $client_install_cmd_opts_no_ntp = ''
  } else {
    $client_install_cmd_opts_no_ntp = '--no-ntp'
  }

  if $easy_ipa::enable_dns_updates {
    $client_install_cmd_opts_dns_updates = '--enable-dns-updates'
  } else {
    $client_install_cmd_opts_dns_updates = ''
  }

  if $easy_ipa::enable_hostname {
    $client_install_cmd_opts_hostname = "--hostname=${fact('networking.fqdn')}"
  } else {
    $client_install_cmd_opts_hostname = ''
  }

  if $force_join {
    $client_install_cmd_opts_force_join= '--force-join'
  } else {
    $client_install_cmd_opts_force_join = ''
  }

  $client_install_cmd = "\
/usr/sbin/ipa-client-install \
  --server=${easy_ipa::ipa_master_fqdn} \
  --realm=${easy_ipa::final_realm} \
  --domain=${easy_ipa::domain} \
  --principal='${easy_ipa::domain_join_principal}' \
  --password='${easy_ipa::final_domain_join_password}' \
  ${client_install_cmd_opts_dns_updates} \
  ${client_install_cmd_opts_hostname} \
  ${client_install_cmd_opts_mkhomedir} \
  ${client_install_cmd_opts_fixed_primary} \
  ${client_install_cmd_opts_no_ntp} \
  ${client_install_cmd_opts_force_join} \
  ${easy_ipa::opt_no_ssh} \
  ${easy_ipa::opt_no_sshd} \
  --unattended"

  exec { "client_install_${fact('networking.fqdn')}":
    command   => $client_install_cmd,
    timeout   => 0,
    unless    => "cat /etc/ipa/default.conf | grep -i \"${easy_ipa::domain}\"",
    creates   => '/etc/ipa/default.conf',
    logoutput => false,  # prevent passphrases from appearing in puppet log
    provider  => 'shell',
    require   => Package[$package_name],
  }

  if fact('os.family') == 'Debian' and $easy_ipa::mkhomedir {
    contain easy_ipa::client::debian
  }
}
