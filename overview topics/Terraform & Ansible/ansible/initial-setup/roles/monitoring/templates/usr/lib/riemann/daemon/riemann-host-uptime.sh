#!/bin/bash
exec 2>&1
sleep 20
echo "checking riemann-host-uptime .."
{% if ansible_facts['distribution'] == "CentOS" %}
exec perl /usr/lib/riemann/plugins/check_uptime.pl -h {{ ansible_hostname }} -r {{ riemann_host }}  -l 120 
{% else %}
exec perl /usr/lib/riemann/plugins/check_uptime.pl -h {{ ansible_hostname }}.{{ ansible_domain }} -r {{ riemann_host }}  -l 120 
{% endif %}
