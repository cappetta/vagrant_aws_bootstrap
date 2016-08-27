#!/bin/bash


sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum install -y puppet-server

# Install puppet modules before launching puppet scripts - these can be executed locally as the application user
puppet module install puppetlabs-apt
puppet module install puppetlabs-motd
puppet module install puppetlabs-java
puppet module install stankevich-python
puppet module install adamcrews-nessus

sudo yum install -y epel-release
sudo yum install -y openconnect libffi-devel.x86_64 htop openssl-devel libxslt-devel.x86_64 libxml2-devel.x86_64
sudo yum install -y ftp://ftp.pbone.net/mirror/li.nux.ro/download/nux/dextop/el7/x86_64/terminator-0.97-6.el7.nux.noarch.rpm