##Impala

[![Build Status](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-impala.svg?branch=master)](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-impala) [![Puppet Forge](https://img.shields.io/puppetforge/v/cesnet/impala.svg)](https://forge.puppetlabs.com/cesnet/impala)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with impala](#setup)
    * [What impala affects](#affects)
    * [Setup requirements](#requirements)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Beginning with Impala](#begin)
    * [Cluster with more HDFS Name nodes](#multinn)
    * [Enable security](#security)
    * [SSL support](#ssl)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Module Parameters (impala class)](#class-impala)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

<a name="module-description"></a>
## Module Description

Management of Cloudera Impala cluster. All services can be separated across all nodes or collocated as needed.

Puppet >= 3.x is required.

Supported are:

* **Debian 7/wheezy**
* **Debian 8/jessie**
* **Ubuntu 14/trusty**
* **RHEL and clones**

Tested with CDH 5.4.7/5.5.0/5.10.0, Impala 2.2.0/2.3.0/2.5.0/2.7.0.

<a name="setup"></a>
## Setup

<a name="affects"></a>
### What impala affects

* Packages: installs Impala packages as needed
* Files modified:
 * */etc/impala/conf/\**
 * */etc/default/impala*
 * */usr/local/sbin/impmanager* (when requested in *features*)
 * */usr/local/bin/impala* (when not disabled in *features*)
* Alternatives:
 * alternatives are used for /etc/impala/conf
 * this module switches to the new alternative by default, so the original configuration can be kept intact
* Helper files:
 * */var/lib/impala/.puppet-\**
* Users:
 * *impala* system user and group are created (from packages or by puppet)
* Secret Files:
 * permissions of keytab are modified (default location: */etc/security/keytabs/impala.service.keytab*)
 * certificate files are copied to */var/lib/impala/\*.pem*
* Services: setup and start Impala services as needed (catalog, server, statestore)

<a name="requirements"></a>
### Setup Requirements

#### Hadoop cluster

Hadoop cluster is required. This puppet module should be applied after the Hadoop cluster is orchestrated. For example when using *cesnet-hadoop* module:

    Class['::hadoop::common::hdfs::config'] -> Class['::impala::common::config']
    Class['::hbase::common::config'] -> Class['::impala::common::config']

Some settings of Hadoop cluster are required:

* *dfs.datanode.hdfs-blocks-metadata.enabled*=*true*
* *dfs.client.read.shortcircuit*=*true*
* *dfs.domain.socket.path* set to location writable by datanodes

Native Hadoop library should be installed.

It is not recommended to install impala nodes on HDFS Name Node: installing on Name Nodes provides no additional data locality, and executing queries with such a configuration might cause memory contention and negatively impact the HDFS Name Node.

#### Hive

**Hive metastore** service is required. You can use *cesnet-hive* puppet module for it (*hive* and *hive::metastore* classes), recommended with MySQL or PostgreSQL database backends (*puppetlabs-postgresql* or *puppetlabs-mysql* puppet modules for example).

**Hive group** (group ownership of HDFS directory */user/hive/warehouse*) must be assigned to the *impala* user.

This is handled automatically. Just make sure the *group* parameter has the proper value (the same as used in hive), defaults are OK.

 1. In deployment with Sentry: we're is using 'hive' group by default and impala is assigned to that group:

    usermod -G hive -a impala

 2. In deployment without Sentry: we're using 'users' group by default and impala is assigned to that group:

    usermod -G users -a impala

<a name="usage"></a>
## Usage

<a name="begin"></a>
### Beginning with Impala

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

<a name="multinn"></a>
###Cluster with more HDFS Name nodes

If there are used more HDFS Name Nodes in the Hadoop cluster (high availability, namespaces, ...), it is needed to have 'impala' system user on all of them to authorization work properly. You could install Impala daemons (using *impala::server*), but just creating the user is enough (using *impala::user*).

Note, the *impala::hdfs* class is available too. It is not needed to use this class (it is here only for similarity with other addons), but it includes the *impala::user*, so *impala::hdfs* can be called instead.

**Example**:

    node <HDFS_NAMENODE> {
      include ::impala::hdfs
    }

    node <HDFS_OTHER_NAMENODE> {
      include ::impala::user
    }

<a name="Security"></a>
###Enable security

SASL GSSAPI module must be installed (installation is not part of this module yet).

Parameters:

* *realm*: Kerberos realm, non-empty value enables the security
* *keytab*

Client side:

*-k, --kerberos* option must be used in *impala-shell* after enabling security.

<a name="ssl"></a>
###SSL support

Certificate files must be prepared before launching *impala* puppet module:

* */etc/grid-security/ca-chain.pem*
* */etc/grid-security/hostcery.pem*
* */etc/grid-security/hostkey.pem*

Possible parameters:

* *https*: **true**, **false** (or undef)
* *https_cachain*
* *https_certificate*
* *https_private_key*

Client side:

*--ssl* option must be used in *impala-shell* after enabling SSL.

*--ca_cert* can be used for verifying of impala certificates, but we don't recommend it as there are some limitations (altSubjName is not supported).

<a name="reference"></a>
## Reference

* [**`impala`**](#class-impala)
* **`impala::catalog`**: Impala Catalog (one in the cluster)
* `impala::catalog::config`
* `impala::catalog::install`
* `impala::catalog::service`
* `impala::common::config`
* `impala::common::daemon`
* `impala::common::install`
* `impala::common::postinstall`
* **`impala::frontend`**: Impala Frontend (on client)
* `impala::frontend::config`
* `impala::frontend::install`
* **`impala::hdfs`**: HDFS initialization
* `impala::params`
* **`impala::server`**: Impala Server (mostly on each Hadoop Data Node)
* `impala::server::config`
* `impala::server::install`
* `impala::server::service`
* **`impala::statestore`**: Impala Statestore (one in the cluster)
* `impala::statestore::config`
* `impala::statestore::install`
* `impala::statestore::service`
* **`impala::user`**: Create impala system user, if needed

<a name="class-impala"></a>
### `impala` class

Configure Impala Puppet Module.

####`alternatives`

Switches the alternatives used for the configuration. Default: 'cluster' (Debian) or undef.

It can be used only when supported (for example with Cloudera distribution).

####`catalog_hostname`

Default: $::fqdn.

####`debug_enable`

Install also debug package and enable core dumps. Default: false.

####`group`

Hive group on HDFS. Default: 'users' (without sentry), 'hive' (with sentry).

*impala* user is added to this group.

####`features`

Enable additional features. Default: { launcher => true }.

Available features:

* **launcher**: script in /usr/local to launch impala client
* **manager**: script in /usr/local to start/stop all daemons relevant for given node

####`https`

Enable SSL. Default: undef.

####`https_cachain`

SSL CA chain file. Default: '/etc/grid-security/ca-chain.pem'.

It is optional, you can disable it by using **::undef**. Without the CA chain servers won't check the certificates between Impala daemons.

####`https_certificate`

SSL certificate file. Default: '/etc/grid-security/hostcert.pem'.

####`https_private_key`

SSL certificate key. Default: '/etc/grid-security/hostkey.pem'.

The certificate key must be without passphrase.

####`keytab`

Impala keytab file for catalog and statestore services. Default: '/etc/security/keytab/impala.service.keytab'.

It must contain principals:

* impala/&lt;HOSTNAME&gt;@&lt;REALM&gt;
* HTTP/&lt;HOSTNAME&gt;@&lt;REALM&gt;

####`parameters`

Daemon parameters to set. Default: undef.

Value is a hash with *catalog*, *server*, and *statestore* keys.

####`realm`

Kerberos realm. Default: undef.

Non-empty value enables Kerberos security.

####`servers`

Array of Impala server hostnames. Default: [$::fqdn].

####`statestore_hostname`

Statestore service hostname. Default: $::fqdn.

####`udf_enable`

Installs also headers on the frontend for development of user defined queries. Default: true.

<a name="limitations"></a>
## Limitations

Hadoop cluster and Hive metastore is required. See [Setup Requirements](#requirements).

This module setup Impala cluster and tries to not limit generic usage by doing other stuff. You can have your own repository with Hadoop SW, you can select which Kerberos implementation, or Java version to use. All of that you will probably already have for the Hadoop cluster.

You must install also SASL GSSAPI module package when using security.

Usage with sentry has not been tested.

<a name="development"></a>
## Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-impala](https://github.com/MetaCenterCloudPuppet/cesnet-impala)
* Issues: [https://github.com/MetaCenterCloudPuppet/cesnet-impala/issues](https://github.com/MetaCenterCloudPuppet/cesnet-impala/issues)
* Tests: see .travis.yml
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
