manila:
  server:
    region: RegionOne
    enabled: true
    version: pike
    bind:
      host: 127.0.0.1
      port: 8977
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      tenant: service
      user: manila
      password: misterio
      endpoint_type: internalURL
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: manila
      user: manila
      password: misterio
    cache:
      engine: memcached
      members:
        - host: 127.0.0.1
        - host: 127.0.0.1
        - host: 127.0.0.1

