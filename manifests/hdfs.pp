# == Class impala::hdfs
#
# HDFS initialiations. Actions necessary to launch on HDFS namenode: Create impala user, if needed.
#
# This class is needed to be launched on HDFS namenode.
#
class impala::hdfs {
  include ::impala::user
}

