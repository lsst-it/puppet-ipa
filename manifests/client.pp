#
# @summary Manage ipa client
#
# @param package_name
#  The name of the package(s) to install.
#
# @param force_join
#   Force the client to join the domain even if it is already joined.
#
class ipa::client (
  Array[String] $package_name = undef,
  Boolean $force_join = false,
) {
  unless $ipa::domain_join_password {
    fail("When creating a ${ipa::ipa_role} the parameter named domain_join_password cannot be empty.")
  }
  unless $ipa::ipa_master_fqdn {
    fail("When creating a ${ipa::ipa_role} the parameter named ipa_master_fqdn cannot be empty.")
  }

  stdlib::ensure_packages($package_name)

  if $ipa::mkhomedir {
    $client_install_cmd_opts_mkhomedir = '--mkhomedir'
  } else {
    $client_install_cmd_opts_mkhomedir = ''
  }

  if $ipa::fixed_primary {
    $client_install_cmd_opts_fixed_primary = '--fixed-primary'
  } else {
    $client_install_cmd_opts_fixed_primary = ''
  }

  if $ipa::configure_ntp {
    $client_install_cmd_opts_no_ntp = ''
  } else {
    $client_install_cmd_opts_no_ntp = '--no-ntp'
  }

  if $ipa::enable_dns_updates {
    $client_install_cmd_opts_dns_updates = '--enable-dns-updates'
  } else {
    $client_install_cmd_opts_dns_updates = ''
  }

  if $ipa::enable_hostname {
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
  --server=${ipa::ipa_master_fqdn} \
  --realm=${ipa::final_realm} \
  --domain=${ipa::domain} \
  --principal='${ipa::domain_join_principal}' \
  --password=\"\${IPA_DOMAIN_JOIN_PASSWORD}\" \
  ${client_install_cmd_opts_dns_updates} \
  ${client_install_cmd_opts_hostname} \
  ${client_install_cmd_opts_mkhomedir} \
  ${client_install_cmd_opts_fixed_primary} \
  ${client_install_cmd_opts_no_ntp} \
  ${client_install_cmd_opts_force_join} \
  ${ipa::opt_no_ssh} \
  ${ipa::opt_no_sshd} \
  --unattended"

  exec { 'ipa-client-install':
    environment => "IPA_DOMAIN_JOIN_PASSWORD=${ipa::domain_join_password}",
    command     => $client_install_cmd,
    timeout     => 0,
    unless      => "cat /etc/ipa/default.conf | grep -i \"${ipa::domain}\"",
    creates     => '/etc/ipa/default.conf',
    logoutput   => on_failure,
    provider    => shell,
    require     => Package[$package_name],
  }

  if fact('os.family') == 'Debian' and $ipa::mkhomedir {
    contain ipa::client::debian
  }
}
