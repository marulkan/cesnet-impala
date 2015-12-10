# == Class impala::hdfs
#
# HDFS initialiation. Actions necessary to launch on HDFS namenode: Create impala user, if needed.
#
# This class is not needed (only here for consistency). Expected to be launched on one HDFS namenode.
#
class impala::hdfs {
  include ::impala::user
}

