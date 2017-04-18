# == Class impala::frontend::config
#
class impala::frontend::config {
  include ::stdlib
  contain impala::common::config

  if ($impala::features['launcher']) {
    $realm = $impala::realm
    $https = $impala::https
    $https_cachain = $impala::https_cachain
    file { '/usr/local/bin/impala':
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      alias   => 'launcher',
      content => template('impala/launcher.sh.erb'),
    }
    ensure_resource('file', '/usr/local/share/hadoop', {
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    })
    file { '/usr/local/share/hadoop/impala-servers':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      alias   => 'servers',
      content => template('impala/servers.erb'),
    }
  } else {
    file { '/usr/local/bin/impala':
      ensure => 'absent',
    }
    file { '/usr/local/share/hadoop/impala-servers':
      ensure => 'absent',
    }
  }
}
