#!/bin/bash
# Install Time Machine service on CentOS 7
# http://netatalk.sourceforge.net/wiki/index.php/Netatalk_3.1.7_SRPM_for_Fedora_and_CentOS
# http://confoundedtech.blogspot.com/2011/07/draft-draft-ubuntu-as-apple-time.html
# https://zitseng.com/archives/6182
# https://gist.github.com/darcyliu/f3db52d6d60ef4f4f4ef

sudo yum install -y avahi-devel bison cracklib-devel dbus-devel dbus-glib-devel docbook-style-xsl flex libacl-devel libattr-devel libdb-devel libevent-devel libgcrypt-devel krb5-devel mysql-devel openldap-devel openssl-devel pam-devel quota-devel systemtap-sdt-devel tcp_wrappers-devel libtdb-devel tracker-devel

wget http://www003.upp.so-net.ne.jp/hat/files/netatalk-3.1.8-0.1.4.fc24.src.rpm
rpmbuild --rebuild netatalk-3.1.8-0.1.4.fc24.src.rpm

sudo yum install -y dconf
rpm -ivh ~/rpmbuild/RPMS/x86_64/netatalk-3.1.8-0.1.4.el7.centos.x86_64.rpm

cat > /etc/netatalk/afp.conf <<EOF
[Time Machine]
path = /opt/timemachine
valid users = tmbackup
time machine = yes
EOF

useradd -M tmbackup
mkdir -p /opt/timemachine
chown tmbackup:tmbackup /opt/timemachine

systemctl enable netatalk
systemctl start netatalk

cat > /etc/avahi/services/afpd.service <<EOF
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
<name replace-wildcards="yes">%hafp</name>
<service>
<type>_afpovertcp._tcp</type>
<port>548</port>
</service>
<service>
<type>_device-info._tcp</type>
<port>0</port>
<txt-record>model=Xserve</txt-record>
</service>
</service-group>
EOF
systemctl restart avahi-daemon

# netatalk ports
firewall-cmd --zone=public --permanent --add-port=548/tcp
firewall-cmd --zone=public --permanent --add-port=548/udp
firewall-cmd --zone=public --permanent --add-port=5353/tcp
firewall-cmd --zone=public --permanent --add-port=5353/udp
systemctl restart firewalld

# set password for tmbackup
passwd tmbackup