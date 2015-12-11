# == Class impala::user
#
# Create impala system user, if needed. The impala user is required on the all HDFS namenodes to autorization work properly and we don't need to install impala just for the user. It's good to have this user also on frontends.
#
# It is better to handle creating the user by the packages, so we recommend dependency on installation classes or Impala packages.
#
class impala::user {
  group { 'impala':
    ensure => present,
    system => true,
  }
  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      user { 'impala':
        ensure     => present,
        system     => true,
        comment    => 'Apache Impala',
        gid        => ['impala', $::impala::_group],
        home       => $::impala::homedir,
        managehome => true,
        password   => '!!',
        shell      => '/sbin/nologin',
      }
    }
    /Debian|RedHat/: {
      user { 'impala':
        ensure     => present,
        system     => true,
        comment    => 'Impala',
        gid        => ['impala', $::impala::_group],
        home       => $::impala::homedir,
        managehome => true,
        password   => '!!',
        shell      => '/bin/false',
      }
    }
    default: {
      fail("${::osfamily}/${::operatingsystem} not supported")
    }
  }
  Group['impala'] -> User['impala']
}
