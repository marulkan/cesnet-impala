# == Class impala::server::service
#
class impala::server::service {
  service { $impala::daemons['server']:
    ensure => 'running',
    enable => true,
  }
}
