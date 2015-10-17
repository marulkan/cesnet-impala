# == Class impala::common::config
#
# Common configuration for Impala.
#
class impala::common::config {
  concat { "${impala::confdir}/core-site.xml":
    group => 'root',
    mode  => '0644',
    owner => 'root',
  }
  concat::fragment { 'impala-orig-core-site.xml':
    order   => 1,
    content => read_conf_fragment("${impala::hadoop_confdir}/core-site.xml"),
    target  => "${impala::confdir}/core-site.xml",
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
  concat::fragment { 'impala-orig-hdfs-site.xml':
    order   => 1,
    content => read_conf_fragment("${impala::hadoop_confdir}/hdfs-site.xml"),
    target  => "${impala::confdir}/hdfs-site.xml",
  }
  concat::fragment { 'impala-specific-hdfs-site.xml':
    content => template('impala/hdfs-site.xml.erb'),
    order   => 2,
    target  => "${impala::confdir}/hdfs-site.xml",
  }

  if file_exists("${impala::hbase_confdir}/hbase-site.xml") {
    file { "${impala::confdir}/hbase-site.xml":
      ensure => link,
      target => "${impala::hbase_confdir}/hbase-site.xml",
    }
  } else {
    warning("Config file ${impala::hbase_confdir}/hbase-site.xml does not exist!")
  }

  if file_exists("${impala::hive_confdir}/hive-site.xml") {
    file { "${impala::confdir}/hive-site.xml":
      ensure => link,
      target => "${impala::hive_confdir}/hive-site.xml",
    }
  } else {
    warning("Config file ${impala::hive_confdir}/hive-site.xml does not exist!")
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
