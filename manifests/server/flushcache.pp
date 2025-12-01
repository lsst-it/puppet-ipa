#
# @summary Manage cache flushing
#
# @api private
class ipa::server::flushcache {
  assert_private()

  #TODO: nscd should be called on both platforms.
  if fact('os.family') == 'RedHat' {
    $ipa_fluch_cache_cmd = "\
if [ -x /usr/sbin/sss_cache ]; then \
  /usr/sbin/sss_cache -UGNA >/dev/null 2>&1 ; \
else \
  /usr/bin/find /var/lib/sss/db -type f -exec rm -f \"{}\" ; ; \
fi"
  } elsif fact('os.family') == 'Debian' {
    $ipa_fluch_cache_cmd = "\
if [ -x /usr/sbin/nscd ]; then \
  /usr/sbin/nscd -i passwd -i group -i netgroup -i automount >/dev/null 2>&1 ; \
elif [ -x /usr/sbin/sss_cache ]; then \
  /usr/sbin/sss_cache -UGNA >/dev/null 2>&1 ; \
else \
  /usr/bin/find /var/lib/sss/db -type f -exec rm -f \"{}\" ; ; \
fi"
  } else {
    fail('The class ipa::flushcache is only written for RedHat and Debian.')
  }

  exec { 'ipa_flushcache':
    command     => "/bin/bash -c ${ipa_fluch_cache_cmd}",
    returns     => ['0','1','2'],
    refreshonly => true,
  }
}
