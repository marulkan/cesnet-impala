# == Class impala::common::daemon
#
# Daemon-specific configuration.
#
class impala::common::daemon {
  $catalog_hostname = $impala::catalog_hostname
  $statestore_hostname = $impala::statestore_hostname
  $debug_enable = $impala::debug_enable
  $realm = $impala::realm
  file { $impala::env_file:
    group   => 'root',
    mode    => '0644',
    owner   => 'root',
    content => template('impala/env.erb'),
  }

  if $impala::realm and $impala::realm != '' {
    file { $impala::keytab:
      group => 'impala',
      mode  => '0400',
      owner => 'impala',
    }
  }
}
