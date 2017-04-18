# == Class impala::statestore
#
# Impala Statestore (one in the cluster). It is optional, but recommended deamon providing more robustness.
#
class impala::statestore {
  include ::impala::statestore::install
  include ::impala::statestore::config
  include ::impala::statestore::service

  Class['::impala::statestore::install']
  -> Class['::impala::statestore::config']
  ~> Class['::impala::statestore::service']
  -> Class['::impala::statestore']
}
