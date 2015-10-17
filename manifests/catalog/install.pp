# == Class impala::catalog::install
#
# Install Impala Catalog.
#
class impala::catalog::install {
  include ::impala::common::install
  contain impala::common::postinstall

  package { $::impala::packages['catalog']:
    ensure => present,
  }
  ->
  Class['impala::common::postinstall']
}
