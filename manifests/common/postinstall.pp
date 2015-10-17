# == Class impala::common::postinstall
#
# Preparation steps after installation. It switches impala-conf alternative, if enabled.
#
class impala::common::postinstall {
  ::hadoop_lib::postinstall{ 'impala':
    alternatives => $::impala::alternatives,
  }
}
