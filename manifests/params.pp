#
# @summary Prevent havoc on unsupported operating systems.
#
# Traditionally this file would be used to abstract away operating system
# differences. Right now the main purpose is to prevent easy_ipa classes from
# causing havoc (e.g. partial configurations) on unsupported operating systems
# by failing early rather than later.
#
class easy_ipa::params {
  # These package names are the same on RedHat and Debian derivatives
  $ipa_server_package_name = 'ipa-server'
  $kstart_package_name = 'kstart'
}
