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

{%- if share.shares is defined %}

{%- for name, share_ in share.shares.iteritems() %}

manila_create_share_type_{{ share_.share_type.share_type_name }}:
  cmd.run:
  - names:
    - manila type-create {{ share_.share_type.share_type_name }} {{ share_.share_type.dhss }}


manila_create_share_{{ name }}:
  cmd.run:
  - names:
    - manila create --share-type {{ share_.share_type.share_type_name }} {{ share_.share_proto  }} {{ share_.share_size }} --name {{ name }}
  - require:
    - manila_create_share_type_{{ share_.share_type.share_type_name }}

{%- if share_.share_access is defined %}
{%- for access_type, client_ips in share_.share_access.iteritems() %}
{%- for client_ip in client_ips %}

manila_set_access_{{ access_type }}_{{ client_ip }}:
  cmd.run:
  - names:
    - manila access-allow --access-level {{ access_type }} {{ name }} ip {{ client_ip }}
  - require:
    - manila_create_share_{{ name }}

{%- endfor %}
{%- endfor %}
{%- endif %}

{%- endfor %}
{%- endif %}
{%- endif %}
