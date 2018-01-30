{%- from "manila/map.jinja" import scheduler with context %}
{%- if scheduler.enabled %}
include:
  - manila._common

manila_scheduler_packages:
  pkg.installed:
  - names: {{ scheduler.pkgs }}

{{ scheduler.service }}:
  service.running:
    - enable: true
    - watch:
      - file: /etc/manila/manila.conf
    {%- if scheduler.message_queue.get('ssl',{}).get('enabled', False) %}
    # TODO add common _ssl state.
      - file: rabbitmq_ca_manila_file
    {%- endif %}
    {%- if scheduler.database.get('ssl',{}).get('enabled', False) %}
      - file: mysql_ca_manila_file
    {%- endif %}

{%- endif %}
