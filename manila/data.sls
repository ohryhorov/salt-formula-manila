{%- from "manila/map.jinja" import data with context %}
{%- if data.enabled %}
include:
  - manila._common

manila_data_packages:
  pkg.installed:
  - names: {{ data.pkgs }}

{{ data.service }}:
  service.running:
    - enable: true
    - watch:
      - file: /etc/manila/manila.conf
    {%- if data.message_queue.get('ssl',{}).get('enabled', False) %}
    # TODO add common _ssl state.
      - file: rabbitmq_ca_manila_file
    {%- endif %}
    {%- if data.database.get('ssl',{}).get('enabled', False) %}
      - file: mysql_ca_manila_file
    {%- endif %}

{%- endif %}
