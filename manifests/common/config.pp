# == Class impala::common::config
#
# Common configuration for Impala.
#
class impala::common::config {
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'

  exec { "mkdir -p ${impala::confdir}":
    creates => $impala::confdir,
    path    => $path,
  }
  ->
  file { $impala::confdir:
    ensure => directory,
    links  => 'follow',
  }

  concat { "${impala::confdir}/core-site.xml":
    group => 'root',
    mode  => '0644',
    owner => 'root',
  }
  file { "${impala::homedir}/.puppet-orig-core-site.xml":
    source => "${impala::hadoop_confdir}/core-site.xml",
  }
  ~>
  exec { "head -n -1 ${impala::homedir}/.puppet-orig-core-site.xml > ${impala::homedir}/.puppet-fragment-core-site.xml":
    path        => $path,
    refreshonly => true,
  }
  ~>
  concat::fragment { 'impala-orig-core-site.xml':
    order  => 1,
    source => "${impala::homedir}/.puppet-fragment-core-site.xml",
    target => "${impala::confdir}/core-site.xml",
  }
  concat::fragment { 'impala-specific-core-site.xml':
    content => template('impala/core-site.xml.erb'),
    order   => 2,
    target  => "${impala::confdir}/core-site.xml",
  }

  concat { "${impala::confdir}/hdfs-site.xml":
    group => 'root',
    mode  => '0644',
    owner => 'root',
  }
  file { "${impala::homedir}/.puppet-orig-hdfs-site.xml":
    source => "${impala::hadoop_confdir}/hdfs-site.xml",
  }
  ~>
  exec { "head -n -1 ${impala::homedir}/.puppet-orig-hdfs-site.xml > ${impala::homedir}/.puppet-fragment-hdfs-site.xml":
    path        => $path,
    refreshonly => true,
  }
  ~>
  concat::fragment { 'impala-orig-hdfs-site.xml':
    order  => 1,
    source => "${impala::homedir}/.puppet-fragment-hdfs-site.xml",
    target => "${impala::confdir}/hdfs-site.xml",
  }
  concat::fragment { 'impala-specific-hdfs-site.xml':
    content => template('impala/hdfs-site.xml.erb'),
    order   => 2,
    target  => "${impala::confdir}/hdfs-site.xml",
  }

  file { "${impala::confdir}/hbase-site.xml":
    ensure => link,
    target => "${impala::hbase_confdir}/hbase-site.xml",
  }

  file { "${impala::confdir}/hive-site.xml":
    ensure => link,
    target => "${impala::hive_confdir}/hive-site.xml",
  }

  if ($impala::features['manager']) {
    file { '/usr/local/sbin/impmanager':
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      alias   => 'manager',
      content => template('impala/manager.erb'),
    }
  }
}
