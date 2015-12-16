# == Class impala::common::config
#
# Common configuration for Impala.
#
class impala::common::config {
  include ::impala::user

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

  file { "${impala::confdir}/core-site.xml":
    ensure => link,
    target => "${::impala::hadoop_confdir}/core-site.xml",
  }
  file { "${::impala::confdir}/hdfs-site.xml":
    ensure => link,
    target => "${::impala::hadoop_confdir}/hdfs-site.xml",
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
