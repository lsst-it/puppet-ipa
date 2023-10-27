#
# @summary Manage primary server
#
class easy_ipa::server::master {
  $server_install_cmd = "\
/usr/sbin/ipa-server-install \
  ${easy_ipa::server::server_install_cmd_opts_hostname} \
  --realm=${easy_ipa::final_realm} \
  --domain=${easy_ipa::domain} \
  --admin-password=\"\${IPA_ADMIN_PASSWORD}\" \
  --ds-password=\"\${IPA_DS_PASSWORD}\" \
  ${easy_ipa::server::server_install_cmd_opts_zone_overlap} \
  ${easy_ipa::server::server_install_cmd_opts_dnssec_validation} \
  ${easy_ipa::server::server_install_cmd_opts_setup_dns} \
  ${easy_ipa::server::server_install_cmd_opts_forwarders} \
  ${easy_ipa::server::server_install_cmd_opts_ip_address} \
  ${easy_ipa::server::server_install_cmd_opts_no_ntp} \
  ${easy_ipa::server::server_install_cmd_opts_idstart} \
  ${easy_ipa::server::server_install_cmd_opts_idmax} \
  ${easy_ipa::server::server_install_cmd_opts_no_ui_redirect} \
  ${easy_ipa::server::server_install_cmd_opts_mkhomedir} \
  ${easy_ipa::opt_no_ssh} \
  ${easy_ipa::opt_no_sshd} \
  --unattended"

  exec { 'ipa-server-install':
    environment => [
      "IPA_ADMIN_PASSWORD=${easy_ipa::admin_password}",
      "IPA_DS_PASSWORD=${easy_ipa::directory_services_password}",
    ],
    command     => $server_install_cmd,
    timeout     => 0,
    unless      => '/usr/sbin/ipactl status >/dev/null 2>&1',
    creates     => '/etc/ipa/default.conf',
    logoutput   => on_failure,
    notify      => Easy_ipa::Helpers::Flushcache["server_${easy_ipa::ipa_server_fqdn}"],
  }
  -> cron { 'k5start_root': #allows scp to replicas as root
    command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/1',
    require => Package[$easy_ipa::params::kstart_package_name],
  }
}
