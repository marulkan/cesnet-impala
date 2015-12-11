# == Class: impala
#
# Configure Impala Puppet Module.
#
class impala (
  $catalog_hostname = $::fqdn,
  $statestore_hostname = $::fqdn,
  $servers = [$::fqdn],
  $sentry_hostname = undef,

  $alternatives = '::default',
  $group = undef,
  $features = {},
  $debug_enable = false,
  $udf_enable = true,

  $parameters = undef,
  $properties = undef,
  $realm = undef,
  $keytab = '/etc/security/keytab/impala.service.keytab',
) inherits ::impala::params {
  include ::stdlib

  validate_string($alternatives)

  $dyn_properties = {
    # short-circuit reads
    'dfs.client.read.shortcircuit' => true,
    'dfs.domain.socket.path' => '/var/run/hadoop-hdfs/dn.socket',
    'dfs.client.file-block-storage-locations.timeout.millis' => '10000',
  }
  $_properties = merge($dyn_properties, $properties)

  if $impala::parameters and has_key($impala::parameters, 'catalog') {
    $catalog_parameters = $impala::parameters['catalog']
  } else {
    $catalog_parameters = undef
  }
  if $impala::parameters and has_key($impala::parameters, 'server') {
    $server_parameters = $impala::parameters['server']
  } else {
    $server_parameters = undef
  }
  if $impala::parameters and has_key($impala::parameters, 'statestore') {
    $statestore_parameters = $impala::parameters['statestore']
  } else {
    $statestore_parameters = undef
  }

  $impala_parameters = {
    'catalog' => {
      log_dir => '${IMPALA_LOG_DIR}',
      state_store_host => '${IMPALA_STATE_STORE_HOST}',
      state_store_port => '${IMPALA_STATE_STORE_PORT}',
    },
    'statestore' => {
      log_dir => '${IMPALA_LOG_DIR}',
      state_store_port => '${IMPALA_STATE_STORE_PORT}',
    },
    'server' => {
      log_dir => '${IMPALA_LOG_DIR}',
      catalog_service_host => '${IMPALA_CATALOG_SERVICE_HOST}',
      state_store_host => '${IMPALA_STATE_STORE_HOST}',
      state_store_port => '${IMPALA_STATE_STORE_PORT}',
      use_statestore => '',
      be_port => '${IMPALA_BACKEND_PORT}',
    },
  }
  if $realm and $realm != '' {
    $sec_parameters = {
      'catalog' => {
        keytab_file => $keytab,
        principal => "impala/${catalog_hostname}@${realm}",
      },
      'statestore' => {
        keytab_file => $keytab,
        principal => "impala/${statestore_hostname}@${realm}",
      },
      'server' => {
      },
    }
  } else {
    $sec_parameters = {
      'catalog' => {},
      'statestore' => {},
      'server' => {},
    }
  }
  if $sentry_hostname {
    $_group = pick($group, 'hive')
    $sentry_parameters = {
      'catalog' => {
        sentry_config => '/etc/sentry/conf/sentry-site.xml',
        server_name => $sentry_hostname,
      },
      'statestore' => {
        sentry_config => '/etc/sentry/conf/sentry-site.xml',
        server_name => $sentry_hostname,
      },
      'server' => {
        sentry_config => '/etc/sentry/conf/sentry-site.xml',
        server_name => $sentry_hostname,
      },
    }
  } else {
    $_group = pick($group, 'users')
    $sentry_parameters = {
      'catalog' => {},
      'statestore' => {},
      'server' => {},
    }
  }

  $_parameters = {
    'catalog' => merge($impala_parameters['catalog'], $sec_parameters['catalog'], $sentry_parameters['catalog'], $catalog_parameters),
    'statestore' => merge($impala_parameters['statestore'], $sec_parameters['statestore'], $sentry_parameters['statestore'], $statestore_parameters),
    'server' => merge($impala_parameters['server'], $sec_parameters['server'], $sentry_parameters['server'], $server_parameters),
  }
}
