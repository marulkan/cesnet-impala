# == Class impala::common::install
#
# Install debug package, id enabled.
#
class impala::common::install {
  if $::impala::debug_enable {
    package { $::impala::packages['debug']:
      ensure => present,
    }
  }
}
