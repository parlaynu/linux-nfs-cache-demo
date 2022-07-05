Host vpn-server
  Hostname ${vpn_server_ip}

Host vpn-client
  Hostname ${vpn_client_ip}

Host nfs-server
  Hostname ${nfs_server_ip}
  ProxyJump vpn-server

Host nfs-cache
  Hostname ${nfs_cache_ip}
  ProxyJump vpn-client

Host nfs-client nfs-client-1
  Hostname ${nfs_client_1_ip}
  ProxyJump vpn-client

Host nfs-client-2
  Hostname ${nfs_client_2_ip}
  ProxyJump vpn-client

Host metrics prometheus
  Hostname ${prometheus_ip}
  ProxyJump vpn-client

Host metrics-ports
  Hostname ${prometheus_ip}
  LocalForward 127.0.0.1:3000 127.0.0.1:3000
  LocalForward 127.0.0.1:9090 127.0.0.1:9090
  ProxyJump vpn-client

Host *
  User ${ssh_username}
  IdentityFile ${ssh_key_file}
  IdentitiesOnly yes
