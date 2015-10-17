# == Class impala::frontend::install
#
# Install Impala Shell.
#
class impala::frontend::install {
  package { $::impala::packages['frontend']:
    ensure => present,
  }

  if $::impala::udf_enable {
    package { $::impala::packages['udf']:
      ensure => present,
    }
  }
}
