# == Class impala::catalog
#
# Impala Catalog (one in the cluster).
#
class impala::catalog {
  include ::impala::catalog::install
  include ::impala::catalog::config
  include ::impala::catalog::service

  Class['::impala::catalog::install'] ->
  Class['::impala::catalog::config'] ~>
  Class['::impala::catalog::service'] ->
  Class['::impala::catalog']
}
