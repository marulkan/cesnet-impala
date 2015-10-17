# == Class impala::server::install
#
# Install Impala Server.
#
class impala::server::install {
  include ::impala::common::install
  contain impala::common::postinstall

  package { $::impala::packages['server']:
    ensure => present,
  }
  ->
  Class['impala::common::postinstall']
}
