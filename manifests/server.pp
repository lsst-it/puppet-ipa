#
# @summary Manage IPA server install
#
# @param package_name
#  The name of the package(s) to install.
#
class ipa::server (
  Array[String] $package_name = undef,
) {
  if $ipa::ipa_role != 'master' { # if replica or client
    unless $ipa::ipa_master_fqdn {
      fail("When creating a ${ipa::ipa_role} the parameter named ipa_master_fqdn cannot be empty.")
    }
    unless $ipa::admin_password {
      fail("When creating a ${ipa::ipa_role} the parameter named admin_password cannot be empty.")
    }
  }

  if fact('os.family') == 'RedHat' {
    require ipa::server::redhat
  }

  stdlib::ensure_packages($package_name)

  $dns_packages = [
    'ipa-server-dns',
    'bind-dyndb-ldap',
  ]

  if $ipa::final_configure_dns_server {
    stdlib::ensure_packages($dns_packages)
  }

  $server_install_cmd_opts_idstart = "--idstart=${ipa::idstart}"

  $server_install_cmd_opts_idmax = $ipa::idmax ? {
    undef   => '',
    default => "--idmax=${ipa::idmax}"
  }

  if $ipa::allow_zone_overlap {
    $server_install_cmd_opts_zone_overlap = '--allow-zone-overlap'
  } else {
    $server_install_cmd_opts_zone_overlap = ''
  }

  if $ipa::no_dnssec_validation {
    $server_install_cmd_opts_dnssec_validation = '--no-dnssec-validation'
  } else {
    $server_install_cmd_opts_dnssec_validation = ''
  }

  if $ipa::enable_hostname {
    $server_install_cmd_opts_hostname = "--hostname=${ipa::ipa_server_fqdn}"
  } else {
    $server_install_cmd_opts_hostname = ''
  }

  if $ipa::enable_ip_address {
    $server_install_cmd_opts_ip_address = "--ip-address ${ipa::ip_address}"
  } else {
    $server_install_cmd_opts_ip_address = ''
  }

  if $ipa::final_configure_dns_server {
    $server_install_cmd_opts_setup_dns = '--setup-dns'
  } else {
    $server_install_cmd_opts_setup_dns = ''
  }

  if $ipa::configure_replica_ca {
    $server_install_cmd_opts_setup_ca = '--setup-ca'
  } else {
    $server_install_cmd_opts_setup_ca = ''
  }

  if $ipa::configure_ntp {
    $server_install_cmd_opts_no_ntp = ''
  } else {
    $server_install_cmd_opts_no_ntp = '--no-ntp'
  }

  if $ipa::final_configure_dns_server {
    if size($ipa::custom_dns_forwarders) > 0 {
      $server_install_cmd_opts_forwarders = join(
        prefix(
          $ipa::custom_dns_forwarders,
        '--forwarder '),
        ' '
      )
    }
    else {
      $server_install_cmd_opts_forwarders = '--no-forwarders'
    }
  }
  else {
    $server_install_cmd_opts_forwarders = ''
  }

  if $ipa::no_ui_redirect {
    $server_install_cmd_opts_no_ui_redirect = '--no-ui-redirect'
  } else {
    $server_install_cmd_opts_no_ui_redirect = ''
  }

  if $ipa::mkhomedir {
    $server_install_cmd_opts_mkhomedir = '--mkhomedir'
  } else {
    $server_install_cmd_opts_mkhomedir = ''
  }

  if $ipa::ipa_role == 'master' {
    contain 'ipa::server::master'

    Class['ipa::server::master']
    -> Service['ipa']
  } elsif $ipa::ipa_role == 'replica' {
    contain 'ipa::server::replica'

    Class['ipa::server::replica']
    -> Service['ipa']
  }

  include ipa::server::flushcache

  service { 'ipa':
    ensure => running,
    enable => true,
  }
}
