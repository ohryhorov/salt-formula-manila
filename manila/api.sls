{%- from "manila/map.jinja" import api with context %}
{%- if api.enabled %}
include:
  - manila._common

manila_api_packages:
  pkg.installed:
  - names: {{ api.pkgs }}

manila_install_database:
  cmd.run:
  - names:
    - manila-manage --config-file /etc/manila/manila.conf db sync
  - require:
    - file: /etc/manila/manila.conf

{{ api.service }}:
  service.running:
    - enable: true
    - watch:
      - file: /etc/manila/manila.conf
      - file: /etc/manila/policy.json
    {%- if api.message_queue.get('ssl',{}).get('enabled', False) %}
    # TODO add common _ssl state.
      - file: rabbitmq_ca_manila_file
    {%- endif %}
    {%- if api.database.get('ssl',{}).get('enabled', False) %}
      - file: mysql_ca_manila_file
    {%- endif %}

/etc/manila/policy.json:
  file.managed:
  - source: salt://manila/files/{{ api.version }}/policy.json
  - template: jinja
  - require:
    - pkg: manila_api_packages

manialla_site_enabled:
  apache_site.enabled:
    - name: wsgi_manila

{%- endif %}
