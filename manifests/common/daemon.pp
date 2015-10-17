# == Class impala::common::daemon
#
# Daemon-specific configuration.
#
class impala::common::daemon {
  $env = $impala::env_file
  file { $env:
    group   => 'root',
    mode    => '0644',
    owner   => 'root',
    content => template('impala/env.erb'),
  }
}
