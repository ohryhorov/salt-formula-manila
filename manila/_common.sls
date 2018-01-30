{%- from "manila/map.jinja" import common with context %}

manila_common_pkgs:
  pkg.installed:
    - name: 'manila-common'
    - install_recommends: False

/etc/manila/manila.conf:
  file.managed:
  - source: salt://manila/files/{{ common.version }}/manila.conf
  - template: jinja
  - require:
    - pkg: manila_common_pkgs

{%- if common.message_queue.get('ssl',{}).get('enabled', False) %}
rabbitmq_ca_manila_file:
{%- if common.message_queue.ssl.cacert is defined %}
  file.managed:
    - name: {{ common.message_queue.ssl.cacert_file }}
    - contents_pillar: common:message_queue:ssl:cacert
    - mode: 0444
    - makedirs: true
{%- else %}
  file.exists:
   - name: {{ common.message_queue.ssl.get('cacert_file', common.cacert_file) }}
{%- endif %}
{%- endif %}

{%- if common.database.get('ssl',{}).get('enabled', False) %}
mysql_ca_manila_file:
{%- if common.database.ssl.cacert is defined %}
  file.managed:
    - name: {{ common.databse.ssl.cacert_file }}
    - contents_pillar: common:database:ssl:cacert
    - mode: 0444
    - makedirs: true
{%- else %}
  file.exists:
   - name: {{ common.database.ssl.get('cacert_file', common.cacert_file) }}
{%- endif %}
{%- endif %}
