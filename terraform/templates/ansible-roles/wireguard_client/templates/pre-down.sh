#!/usr/bin/env bash

iptables -P FORWARD ACCEPT
iptables -D FORWARD -i {{ iface_name }} -o {{ iface_name }} -j ACCEPT
iptables -D FORWARD -i wg0 -o {{ iface_name }} -d {{ local_cidr_block }} -j ACCEPT
iptables -D FORWARD -o wg0 -i {{ iface_name }} -s {{ local_cidr_block }} -j ACCEPT


