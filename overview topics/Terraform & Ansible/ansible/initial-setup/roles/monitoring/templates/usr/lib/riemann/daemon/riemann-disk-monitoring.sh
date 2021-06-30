#!/bin/bash
exec 2>&1
sleep 30
echo "Starting riemann disk monitoring .."
{% if ansible_facts['distribution'] == 'CentOS' %}
exec perl /usr/lib/riemann/plugins/check_disk.pl -h {{ ansible_hostname }} -r {{ riemann_host }} -d 0.88 -f 0.85
{% else %}
exec perl /usr/lib/riemann/plugins/check_disk.pl -h {{ ansible_hostname }}.{{ ansible_domain }} -r {{ riemann_host }} -d 0.88 -f 0.85
{% endif %}
