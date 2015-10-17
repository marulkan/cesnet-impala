# == Class impala::statestore::config
#
class impala::statestore::config {
  contain impala::common::config
  contain impala::common::daemon
}
