#
# @summary Prevent havoc on unsupported operating systems.
#
# Traditionally this file would be used to abstract away operating system
# differences. Right now the main purpose is to prevent easy_ipa classes from
# causing havoc (e.g. partial configurations) on unsupported operating systems
# by failing early rather than later.
#
class easy_ipa::params {
  case fact('os.family') {
    'RedHat': {
      $named_conf_d = '/etc/named/conf.d'
    }
    'Debian': {
      case fact('os.distro.codename') {
        /(trusty|xenial|bionic|focal|bullseye|jammy)/: {
        }
        default: {
          fail('ERROR: unsupported operating system')
        }
      }
    }
    default: {
      fail('ERROR: unsupported operating system!')
    }
  }

  # These package names are the same on RedHat and Debian derivatives
  $ipa_server_package_name = 'ipa-server'
  $kstart_package_name = 'kstart'
}
