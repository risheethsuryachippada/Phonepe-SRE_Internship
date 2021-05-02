### Ansible Aerospike Tasks

> VM  Configuration

node name | IP address
:--: | :--:
`control-node` | 172.10.0.10
`m-node-1` | 172.10.0.1
`m-node-2` | 172.10.0.2
`m-node-3` | 172.10.0.6

`All tasks playbook` : [tasks.yml]

* Install and configure 3 node Aerospike cluster version 4.8.0.6.

    * File : [aero_ins_clusconf.yml]

    * Has 2 roles, one to install aerospike and another to check the cluster status and give result in debug console.

    ansible-galaxy init roles/<name of role> #to create roles and then assign the playbooks

    ansible-playbook tasks.yml --ask-become-pass #to run the playbook file