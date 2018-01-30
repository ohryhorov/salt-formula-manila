{%- from "manila/map.jinja" import share with context %}
{%- if share.enabled %}
include:
  - manila._common

manila_share_packages:
  pkg.installed:
  - names: {{ share.pkgs }}

{{ share.service }}:
  service.running:
    - enable: true
    - watch:
      - file: /etc/manila/manila.conf
    {%- if share.message_queue.get('ssl',{}).get('enabled', False) %}
    # TODO add common _ssl state.
      - file: rabbitmq_ca_manila_file
    {%- endif %}
    {%- if share.database.get('ssl',{}).get('enabled', False) %}
      - file: mysql_ca_manila_file
    {%- endif %}

{%- endif %}
