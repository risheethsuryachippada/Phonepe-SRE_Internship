#!/bin/bash
echo "Staring riemann health.."
sleep 3
exec 2>&1
{% if ansible_facts['distribution'] == "CentOS" %}
exec riemann-health -h {{ riemann_host }} -e {{ ansible_hostname }} -t 'system-check' -i 30 -l 60 -u 0.9 -r 0.95 -o 1 --load-critical 2 -y 0.92 --memory-critical 0.97 -k cpu load memory
{% else %}
exec riemann-health -h {{ riemann_host }} -e {{ ansible_hostname }}.{{ ansible_domain }} -t 'system-check' -i 30 -l 60 -u 0.9 -r 0.95 -o 1 --load-critical 2 -y 0.92 --memory-critical 0.97 -k cpu load memory
{% endif %}
