#!/bin/bash

rabbitmqctl add_user monitoring monitoring
rabbitmqctl set_user_tags monitoring monitoring

for vhost in $(rabbitmqctl list_vhosts -q | grep -v name); do
	echo $vhost
	rabbitmqctl set_permissions -p $vhost "monitoring" "" "" ""
done
