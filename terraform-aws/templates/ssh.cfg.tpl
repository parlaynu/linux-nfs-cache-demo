Host vpn-server
  Hostname ${vpn_server.public_ip}

Host vpn-client
  Hostname ${vpn_client.public_ip}

Host nfs-server
  Hostname ${nfs_server.private_ip}
  ProxyJump vpn-server

Host nfs-cache
  Hostname ${nfs_cache.private_ip}
  ProxyJump vpn-client

Host nfs-client
  Hostname ${nfs_client.private_ip}
  ProxyJump vpn-client

Host metrics prometheus
  Hostname ${prometheus.private_ip}
  ProxyJump vpn-client

Host metrics-ports
  Hostname ${prometheus.private_ip}
  LocalForward 127.0.0.1:3000 127.0.0.1:3000
  LocalForward 127.0.0.1:9090 127.0.0.1:9090
  ProxyJump vpn-client

Host *
  User ${ssh_username}
  IdentityFile ${ssh_key_file}
  IdentitiesOnly yes
