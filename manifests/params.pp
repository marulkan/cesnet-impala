# == Class impala::params
#
# This class is meant to be called from impala.
# It sets variables according to platform.
#
class impala::params {
  $packages = {
    catalog    => 'impala-catalog',
    frontend   => 'impala-shell',
    server     => 'impala-server',
    statestore => 'impala-state-store',
  }
  $daemons = {
    catalog    => 'impala-catalog',
    server     => 'impala-server',
    statestore => 'impala-state-store',
  }

  $confdir = '/etc/impala/conf'
  $env_file = '/etc/default/impala'
  $hadoop_confdir = '/etc/hadoop/conf'
  $hbase_confdir = '/etc/hbase/conf'
  $hive_confdir = '/etc/hive/conf'
  $impala_homedir = '/var/lib/impala'

  $descriptions = {}
}
