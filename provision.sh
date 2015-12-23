#!/bin/sh
rpm --import http://rex.linux-files.org/RPM-GPG-KEY-REXIFY-REPO.CENTOS5

cat >/etc/yum.repos.d/rex.repo <<EOF
[rex]
name=Fedora \$releasever - \$basearch - Rex Repository
baseurl=https://rex.linux-files.org/CentOS/\$releasever/rex/\$basearch/
enabled=1
EOF

yum install -y rex
rex -f /vagrant/Rexfile ConfigurarMaquina
