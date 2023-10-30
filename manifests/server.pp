#
# @summary Manage IPA server install
#
# @param package_name
#  The name of the package(s) to install.
#
class easy_ipa::server (
  Array[String] $package_name = undef,
) {
  if $easy_ipa::ipa_role != 'master' { # if replica or client
    unless $easy_ipa::ipa_master_fqdn {
      fail("When creating a ${easy_ipa::ipa_role} the parameter named ipa_master_fqdn cannot be empty.")
    }
    unless $easy_ipa::admin_password {
      fail("When creating a ${easy_ipa::ipa_role} the parameter named admin_password cannot be empty.")
    }
  }

  if fact('os.family') == 'RedHat' {
    require easy_ipa::server::redhat
  }

  ensure_packages($package_name)

  $dns_packages = [
    'ipa-server-dns',
    'bind-dyndb-ldap',
  ]

  if $easy_ipa::final_configure_dns_server {
    ensure_packages($dns_packages)
  }

  $server_install_cmd_opts_idstart = "--idstart=${easy_ipa::idstart}"

  $server_install_cmd_opts_idmax = $easy_ipa::idmax ? {
    undef   => '',
    default => "--idmax=${easy_ipa::idmax}"
  }

  if $easy_ipa::allow_zone_overlap {
    $server_install_cmd_opts_zone_overlap = '--allow-zone-overlap'
  } else {
    $server_install_cmd_opts_zone_overlap = ''
  }

  if $easy_ipa::no_dnssec_validation {
    $server_install_cmd_opts_dnssec_validation = '--no-dnssec-validation'
  } else {
    $server_install_cmd_opts_dnssec_validation = ''
  }

  if $easy_ipa::enable_hostname {
    $server_install_cmd_opts_hostname = "--hostname=${easy_ipa::ipa_server_fqdn}"
  } else {
    $server_install_cmd_opts_hostname = ''
  }

  if $easy_ipa::enable_ip_address {
    $server_install_cmd_opts_ip_address = "--ip-address ${easy_ipa::ip_address}"
  } else {
    $server_install_cmd_opts_ip_address = ''
  }

  if $easy_ipa::final_configure_dns_server {
    $server_install_cmd_opts_setup_dns = '--setup-dns'
  } else {
    $server_install_cmd_opts_setup_dns = ''
  }

  if $easy_ipa::configure_replica_ca {
    $server_install_cmd_opts_setup_ca = '--setup-ca'
  } else {
    $server_install_cmd_opts_setup_ca = ''
  }

  if $easy_ipa::configure_ntp {
    $server_install_cmd_opts_no_ntp = ''
  } else {
    $server_install_cmd_opts_no_ntp = '--no-ntp'
  }

  if $easy_ipa::final_configure_dns_server {
    if size($easy_ipa::custom_dns_forwarders) > 0 {
      $server_install_cmd_opts_forwarders = join(
        prefix(
          $easy_ipa::custom_dns_forwarders,
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

  if $easy_ipa::no_ui_redirect {
    $server_install_cmd_opts_no_ui_redirect = '--no-ui-redirect'
  } else {
    $server_install_cmd_opts_no_ui_redirect = ''
  }

  if $easy_ipa::mkhomedir {
    $server_install_cmd_opts_mkhomedir = '--mkhomedir'
  } else {
    $server_install_cmd_opts_mkhomedir = ''
  }

  if $easy_ipa::ipa_role == 'master' {
    contain 'easy_ipa::server::master'
    Class['easy_ipa::server::master']
    -> Class['easy_ipa::config::webui']

    Class['easy_ipa::server::master']
    -> Service['ipa']
  } elsif $easy_ipa::ipa_role == 'replica' {
    contain 'easy_ipa::server::replica'
    Class['easy_ipa::server::replica']
    -> Class['easy_ipa::config::webui']

    Class['easy_ipa::server::replica']
    -> Service['ipa']
  }

  ensure_resource (
    'service',
    'httpd',
    { ensure => 'running' },
  )

  contain 'easy_ipa::config::webui'

  service { 'ipa':
    ensure => running,
    enable => true,
  }

  easy_ipa::helpers::flushcache { "server_${easy_ipa::ipa_server_fqdn}": }
}
