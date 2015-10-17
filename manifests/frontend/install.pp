# == Class impala::frontend::install
#
# Install Impala Shell.
#
class impala::frontend::install {
  package { $::impala::packages['frontend']:
    ensure => present,
  }
}
