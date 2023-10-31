#
# @summary Manage replica install
#
class easy_ipa::server::replica {
  $replica_install_cmd = "\
/usr/sbin/ipa-replica-install \
  --principal=${easy_ipa::domain_join_principal} \
  --admin-password=\"\${IPA_ADMIN_PASSWORD}\" \
  ${easy_ipa::server::server_install_cmd_opts_hostname} \
  --realm=${easy_ipa::final_realm} \
  --domain=${easy_ipa::domain} \
  --server=${easy_ipa::ipa_master_fqdn} \
  ${easy_ipa::server::server_install_cmd_opts_zone_overlap} \
  ${easy_ipa::server::server_install_cmd_opts_dnssec_validation} \
  ${easy_ipa::server::server_install_cmd_opts_setup_dns} \
  ${easy_ipa::server::server_install_cmd_opts_setup_ca} \
  ${easy_ipa::server::server_install_cmd_opts_forwarders} \
  ${easy_ipa::server::server_install_cmd_opts_ip_address} \
  ${easy_ipa::server::server_install_cmd_opts_no_ntp} \
  ${easy_ipa::server::server_install_cmd_opts_no_ui_redirect} \
  ${easy_ipa::server::server_install_cmd_opts_mkhomedir} \
  ${easy_ipa::opt_no_ssh} \
  ${easy_ipa::opt_no_sshd} \
  --unattended"

  exec { 'ipa-replica-install':
    environment => "IPA_ADMIN_PASSWORD=${easy_ipa::admin_password}",
    command     => $replica_install_cmd,
    timeout     => 0,
    unless      => '/usr/sbin/ipactl status >/dev/null 2>&1',
    creates     => '/etc/ipa/default.conf',
    logoutput   => on_failure,
    notify      => Class[easy_ipa::server::flushcache],
  }
  -> cron { 'k5start_root':
    command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/1',
  }
}
