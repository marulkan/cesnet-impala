#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with impala](#setup)
    * [What impala affects](#affects)
    * [Setup requirements](#requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

<a name="module-description"></a>
## Module Description

Management of Cloudera Impala cluster. All services can be separated across all nodes or collocated as needed.

Puppet >= 3.x is required.

Supported are:

* **Debian 7/wheezy**: tested with CDH 5.4.7, Impala 2.2.0
* **Ubuntu 14/trusty**
* **RHEL 6 and clones**

Security is not implemented yet.

<a name="setup"></a>
## Setup

<a name="affects"></a>
### What impala affects

* Packages: installs Impala packages as needed
* Files modified:
 * */etc/impala/conf/\**
 * */usr/local/sbin/impmanager* (when requested in *features*)
* Alternatives:
 * alternatives are used for /etc/impala/conf
 * this module switches to the new alternative by default, so the original configuration can be kept intact
* Services: setup and start Impala services as needed (catalog, server, statestore)

<a name="requirements"></a>
### Setup Requirements

#### Hadoop cluster

Hadoop cluster is required. This puppet module should be applied after the Hadoop cluster is orchestrated. For example when using *cesnet-hadoop* module:

    Class['::hadoop::common::hdfs::config'] -> Class['::impala::common::config']
    Class['::hbase::common::config'] -> Class['::impala::common::config']

*dfs.datanode.hdfs-blocks-metadata.enabled* must be *true* in the Hadoop cluster

Native Hadoop library should be installed.

It is not recommended to install impala on HDFS Name Node: installing on NameNodes provides no additional data locality, and executing queries with such a configuration might cause memory contention and negatively impact the HDFS NameNode.

#### Hive

**Hive metastore** service is required. You can use *cesnet-hive* puppet module for it (*hive* and *hive::metastore* classes), recommended with MySQL or PostgreSQL database backends (*puppetlabs-postgresql* or *puppetlabs-mysql* puppet modules for example).

**Hive group** (group ownership of HDFS directory */user/hive/warehouse*) must be assigned to the *impala* user. Note, Cloudera is using 'hive' group and impala is assigned to that group automatically:

    usermod -G hive -a impala

Example when using 'users' group:

    usermod -G users -a impala

<a name="usage"></a>
## Usage

**Basic example:**

    class { 'impala':
    }

    include ::impala::frontend
    include ::impala::statestore
    include ::impala::catalog
    include ::impala::server

**Cluster example:**

    class { 'impala':
      catalog_hostname    => 'master.example.com',
      statestore_hostname => 'master.example.com',
      servers             => ['node1.example.com', 'node2.example.com', 'node3.example.com'],
    }

    node example.com {
      include ::impala::frontend
    }

    node master.example.com {
      include ::impala::statestore
      include ::impala::catalog
    }

    node /node\d+\.example\.com/ {
      include ::impala::server
    }

<a name="reference"></a>
## Reference

* [**`impala`**](#class-impala)
* **`impala::catalog`**: Impala Catalog (one in the cluster)
* `impala::catalog::config`
* `impala::catalog::install`
* `impala::catalog::service`
* **`impala::frontend`**: Impala Frontend (on client)
* `impala::frontend::config`
* `impala::frontend::install`
* `impala::params`
* **`impala::server`**: Impala Server (mostly on each Hadoop Data Node)
* `impala::server::config`
* `impala::server::install`
* `impala::server::service`
* **`impala::statestore`**: Impala Statestore (one in the cluster)
* `impala::statestore::config`
* `impala::statestore::install`
* `impala::statestore::service`

<a name="class-impala"></a>
### `impala` class

Configure Impala Puppet Module.

####`alternatives`

Switches the alternatives used for the configuration. Default: 'cluster' (Debian) or undef.

It can be used only when supported (for example with Cloudera distribution).

####`catalog_hostname`

Default: $::fqdn.

####`features`

Enable additional features. Default: {}.

Available features:

* **manager**: script in /usr/local to start/stop all daemons relevant for given node

####`properties`

"Raw" properties for hadoop cluster. Default: as needed.

"::undef" value will remove given property set automatically by this module, empty string sets the empty value.

####`servers`

Array of Impala server hostnames. Default: [$::fqdn].

####`statestore_hostname`

Default: $::fqdn.

<a name="limitations"></a>
## Limitations

Hadoop cluster and Hive metastore is required. See [Setup Requirements](#requirements).

This module setup Impala cluster and tries to not limit generic usage by doing other stuff. You can have your own repository with Hadoop SW, you can select which Kerberos implementation, or Java version to use. All of that you will probably already have for the Hadoop cluster.

Security is not implemented yet.

<a name="development"></a>
## Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-impala](https://github.com/MetaCenterCloudPuppet/cesnet-impala)
* Issues: [https://github.com/MetaCenterCloudPuppet/cesnet-impala/issues](https://github.com/MetaCenterCloudPuppet/cesnet-impala/issues)
* Tests: see .travis.yml
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
