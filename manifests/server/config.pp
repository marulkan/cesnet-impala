# == Class impala::server::config
#
class impala::server::config {
  contain impala::common::config
  contain impala::common::daemon
}
