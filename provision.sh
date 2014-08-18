#!/usr/bin/env bash

#install required packages
apt-get update
apt-get install squid3 -y
#copy config file
yes | cp /vagrant/squid.conf /etc/squid3/
#reload with new configuration
service squid3 restart
