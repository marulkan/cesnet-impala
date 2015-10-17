# == Class impala::statestore::install
#
# Install Impala Statestore.
#
class impala::statestore::install {
  contain ::impala::common::postinstall

  package { $::impala::packages['statestore']:
    ensure => present,
  }
  ->
  Class['impala::common::postinstall']
}
