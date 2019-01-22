# == Class impala::common::daemon
#
# Daemon-specific configuration.
#
class impala::common::daemon {
  $debug_enable = $impala::debug_enable
  file { $impala::env_file:
    group   => 'root',
    mode    => '0644',
    owner   => 'root',
    content => template('impala/env.erb'),
  }

  if $impala::realm and $impala::realm != '' {
    if $impala::keytab_source and $impala::keytab_source != '' {
      file { $impala::keytab:
        group  => 'impala',
        mode   => '0400',
        owner  => 'impala',
        source => $impala::keytab_source,
      }
    } else {
      file { $impala::keytab:
        group => 'impala',
        mode  => '0400',
        owner => 'impala',
      }
    }
  }

  if $impala::https {
    file { "${impala::homedir}/hostcert.pem":
      owner  => 'impala',
      group  => 'impala',
      mode   => '0644',
      source => $impala::https_certificate,
    }
    file { "${impala::homedir}/hostkey.pem":
      owner  => 'impala',
      group  => 'impala',
      mode   => '0640',
      source => $impala::https_private_key,
    }
  }
}
