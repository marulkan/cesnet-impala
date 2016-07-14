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
  $https = undef,
  $https_cachain = '/etc/grid-security/ca-chain.pem',
  $https_certificate = '/etc/grid-security/hostcert.pem',
  $https_private_key = '/etc/grid-security/hostkey.pem',
  $udf_enable = true,

  $parameters = undef,
  $realm = undef,
  $keytab = '/etc/security/keytab/impala.service.keytab',
) inherits ::impala::params {
  include ::stdlib

  validate_string($alternatives)

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

  # impala detects hostname without domain ==> also *hostname* parameter
  $impala_parameters = {
    'catalog' => {
      hostname => $::fqdn,
      log_dir => '${IMPALA_LOG_DIR}',
      state_store_host => '${IMPALA_STATE_STORE_HOST}',
      state_store_port => '${IMPALA_STATE_STORE_PORT}',
    },
    'statestore' => {
      hostname => $::fqdn,
      log_dir => '${IMPALA_LOG_DIR}',
      state_store_port => '${IMPALA_STATE_STORE_PORT}',
    },
    'server' => {
      hostname => $::fqdn,
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
      # impala detects hostname without domain ==> $:fqdn instead of _HOST
      'server' => {
        keytab_file => $keytab,
        principal => "impala/${::fqdn}@${realm}",
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
  if ($https) {
    if !$impala::https_certificate or $impala::https_certificate == '' {
      err('"https_certificate" is needed for https support.')
    }
    if !$impala::https_private_key or $impala::https_private_key == '' {
      err('"https_certificate" is needed for https support.')
    }
    $https_parameters = {
      'catalog' => {
        'ssl_server_certificate' => "${impala::homedir}/hostcert.pem",
        'ssl_private_key' => "${impala::homedir}/hostkey.pem",
        'ssl_client_ca_certificate' => $impala::https_cachain,
      },
      'statestore' => {
        'ssl_server_certificate' => "${impala::homedir}/hostcert.pem",
        'ssl_private_key' => "${impala::homedir}/hostkey.pem",
        'ssl_client_ca_certificate' => $impala::https_cachain,
      },
      'server' => {
        'ssl_server_certificate' => "${impala::homedir}/hostcert.pem",
        'ssl_private_key' => "${impala::homedir}/hostkey.pem",
        'ssl_client_ca_certificate' => $impala::https_cachain,
      },
    }
  } else {
    $https_parameters = {
      'catalog' => {},
      'statestore' => {},
      'server' => {},
    }
  }

  $_parameters = {
    'catalog' => merge($impala_parameters['catalog'], $sec_parameters['catalog'], $sentry_parameters['catalog'], $https_parameters['catalog'], $catalog_parameters),
    'statestore' => merge($impala_parameters['statestore'], $sec_parameters['statestore'], $sentry_parameters['statestore'], $https_parameters['statestore'], $statestore_parameters),
    'server' => merge($impala_parameters['server'], $sec_parameters['server'], $sentry_parameters['server'], $https_parameters['server'], $server_parameters),
  }
}
