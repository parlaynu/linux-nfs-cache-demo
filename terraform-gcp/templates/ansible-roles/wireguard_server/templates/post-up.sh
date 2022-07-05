#!/usr/bin/env bash

iptables -A FORWARD -i {{ iface_name }} -o {{ iface_name }} -j ACCEPT
iptables -A FORWARD -i wg0 -o {{ iface_name }} -d {{ local_cidr_block }} -j ACCEPT
iptables -A FORWARD -o wg0 -i {{ iface_name }} -s {{ local_cidr_block }} -j ACCEPT
iptables -P FORWARD DROP

