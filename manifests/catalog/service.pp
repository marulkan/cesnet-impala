# == Class impala::catalog::service
#
class impala::catalog::service {
  service { $impala::daemons['catalog']:
    ensure => 'running',
    enable => true,
  }
}
