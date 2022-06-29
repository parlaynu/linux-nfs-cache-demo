---
server_name: ${server_name}
private_ip: ${private_ip}

nodes:
%{ for k, v in nodes ~}
- name: ${k}
  private_ip: ${v.private_ip}
%{ endfor ~}
