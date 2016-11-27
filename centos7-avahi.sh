#!/bin/bash

sudo yum install -y avahi

systemctl enable avahi-daemon
systemctl start avahi-daemon

firewall-cmd --zone=public --permanent --add-service=mdns
systemctl restart firewalld