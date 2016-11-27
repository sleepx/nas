#!/bin/bash

yum install samba

cat > /etc/samba/smb.conf <<EOF
guest account = nobody
map to guest = bad user
[Media]
 comment = Media Share
 path = /media/nas/Media
 browseable = yes
 guest ok = yes
 writable = no
 read only = yes
EOF

systemctl enable smb
systemctl enable nmb
systemctl start smb
systemctl start nmb

cat > /etc/avahi/services/smbd.service <<EOF
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
<name replace-wildcards="yes">%hsmb</name>
<service>
<type>_smb._tcp</type>
<port>445</port>
</service>
<service>
<type>_device-info._tcp</type>
<port>0</port>
<txt-record>model=LinuxPC</txt-record>
</service>
</service-group>
EOF
systemctl restart avahi-daemon

firewall-cmd --zone=public --permanent --add-service=samba
systemctl restart firewalld
Sign up for free