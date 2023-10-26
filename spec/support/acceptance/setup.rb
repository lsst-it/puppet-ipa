# frozen_string_literal: true

configure_beaker(modules: :metadata) do |host|
  on(host, 'sysctl -w net.ipv6.conf.lo.disable_ipv6=0')
  install_puppet_module_via_pmt_on(host, 'puppet/cron')
  install_puppet_module_via_pmt_on(host, 'puppet/epel')
end
