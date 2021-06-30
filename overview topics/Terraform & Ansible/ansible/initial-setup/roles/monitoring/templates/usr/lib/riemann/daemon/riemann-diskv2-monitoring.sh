#!/bin/bash
exec 2>&1
sleep 30
echo "Starting riemann disk monitoring .."
{% if ansible_facts['distribution'] == 'CentOS' %}
exec perl /usr/lib/riemann/plugins/check_disk_v2.pl -h {{ ansible_hostname }} --riemann_host {{ riemann_host }} -d 0.88 -i 0.85 --ttl 60
{% else %} 
exec perl /usr/lib/riemann/plugins/check_disk_v2.pl -h {{ ansible_hostname }}.{{ ansible_domain }} --riemann_host {{ riemann_host }} -d 0.88 -i 0.85 --ttl 60
{% endif %}
