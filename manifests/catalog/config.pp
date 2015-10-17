# == Class impala::catalog::config
#
class impala::catalog::config {
  contain impala::common::config
  contain impala::common::daemon
}
