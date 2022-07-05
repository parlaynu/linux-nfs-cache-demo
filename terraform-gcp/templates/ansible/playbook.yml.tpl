---
- hosts: gateways
  become: yes
  gather_facts: no
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"
  tasks:
  - import_role:
      name: ${gateway_role}


- hosts: vpn_servers
  become: yes
  gather_facts: no
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"
  tasks:
  - import_role:
      name: ${wireguard_server_role}


- hosts: vpn_clients
  become: yes
  gather_facts: no
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"
  tasks:
  - import_role:
      name: ${wireguard_client_role}


- hosts: all_ubuntu
  become: yes
  gather_facts: no
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"
  tasks:
  - import_role:
      name: ${prometheus_node_role}


- hosts: monitoring
  become: yes
  gather_facts: no
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"
  tasks:
  - import_role:
      name: ${prometheus_role}


- hosts: nfs_servers
  become: yes
  gather_facts: no
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"
  tasks:
  - import_role:
      name: ${nfs_server_role}


- hosts: nfs_caches
  become: yes
  gather_facts: no
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"
  tasks:
  - import_role:
      name: ${nfs_cache_role}


- hosts: nfs_clients_ubuntu
  become: yes
  gather_facts: no
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"
  tasks:
  - import_role:
      name: ${nfs_client_ubuntu_role}


- hosts: all_nfs_ubuntu
  become: yes
  gather_facts: no
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"
  tasks:
  - import_role:
      name: ${fsutils_ubuntu_role}


- hosts: nfs_clients_centos
  become: yes
  gather_facts: no
  tasks:
  - import_role:
      name: ${nfs_client_centos_role}
  - import_role:
      name: ${fsutils_centos_role}

