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
