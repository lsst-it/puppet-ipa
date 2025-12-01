#
# @summary Manage primary server
#
# @api private
class ipa::server::master {
  assert_private()

  $server_install_cmd = "\
/usr/sbin/ipa-server-install \
  ${ipa::server::server_install_cmd_opts_hostname} \
  --realm=${ipa::final_realm} \
  --domain=${ipa::domain} \
  --admin-password=\"\${IPA_ADMIN_PASSWORD}\" \
  --ds-password=\"\${IPA_DS_PASSWORD}\" \
  ${ipa::server::server_install_cmd_opts_zone_overlap} \
  ${ipa::server::server_install_cmd_opts_dnssec_validation} \
  ${ipa::server::server_install_cmd_opts_setup_dns} \
  ${ipa::server::server_install_cmd_opts_forwarders} \
  ${ipa::server::server_install_cmd_opts_ip_address} \
  ${ipa::server::server_install_cmd_opts_no_ntp} \
  ${ipa::server::server_install_cmd_opts_idstart} \
  ${ipa::server::server_install_cmd_opts_idmax} \
  ${ipa::server::server_install_cmd_opts_no_ui_redirect} \
  ${ipa::server::server_install_cmd_opts_mkhomedir} \
  ${ipa::opt_no_ssh} \
  ${ipa::opt_no_sshd} \
  --unattended"

  exec { 'ipa-server-install':
    environment => [
      "IPA_ADMIN_PASSWORD=${ipa::admin_password.unwrap}",
      "IPA_DS_PASSWORD=${ipa::directory_services_password.unwrap}",
    ],
    command     => $server_install_cmd,
    timeout     => 0,
    unless      => '/usr/sbin/ipactl status >/dev/null 2>&1',
    creates     => '/etc/ipa/default.conf',
    logoutput   => on_failure,
    notify      => Class[ipa::server::flushcache],
  }
  -> cron { 'k5start_root': #allows scp to replicas as root
    command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/1',
  }
}
