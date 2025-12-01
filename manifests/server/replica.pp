#
# @summary Manage replica install
#
# @api private
class ipa::server::replica {
  assert_private()

  $replica_install_cmd = "\
/usr/sbin/ipa-replica-install \
  --principal=${ipa::domain_join_principal.unwrap} \
  --admin-password=\"\${IPA_ADMIN_PASSWORD}\" \
  ${ipa::server::server_install_cmd_opts_hostname} \
  --realm=${ipa::final_realm} \
  --domain=${ipa::domain} \
  --server=${ipa::ipa_master_fqdn} \
  ${ipa::server::server_install_cmd_opts_zone_overlap} \
  ${ipa::server::server_install_cmd_opts_dnssec_validation} \
  ${ipa::server::server_install_cmd_opts_setup_dns} \
  ${ipa::server::server_install_cmd_opts_setup_ca} \
  ${ipa::server::server_install_cmd_opts_forwarders} \
  ${ipa::server::server_install_cmd_opts_ip_address} \
  ${ipa::server::server_install_cmd_opts_no_ntp} \
  ${ipa::server::server_install_cmd_opts_no_ui_redirect} \
  ${ipa::server::server_install_cmd_opts_mkhomedir} \
  ${ipa::opt_no_ssh} \
  ${ipa::opt_no_sshd} \
  --unattended"

  exec { 'ipa-replica-install':
    environment => "IPA_ADMIN_PASSWORD=${ipa::admin_password.unwrap}",
    command     => $replica_install_cmd,
    timeout     => 0,
    unless      => '/usr/sbin/ipactl status >/dev/null 2>&1',
    creates     => '/etc/ipa/default.conf',
    logoutput   => on_failure,
    notify      => Class[ipa::server::flushcache],
  }
  -> cron { 'k5start_root':
    command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/1',
  }
}
