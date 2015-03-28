#!/bin/bash
#Disable ICMP redirects
#all
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.all.send_redirects=0

#default
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0

#eth0
sysctl -w net.ipv4.conf.eth0.accept_redirects=0
sysctl -w net.ipv4.conf.eth0.send_redirects=0

#lo
sysctl -w net.ipv4.conf.lo.accept_redirects=0
sysctl -w net.ipv4.conf.lo.send_redirects=0

cp ./etc_quagga/* /etc/quagga
chown quagga:quaggavty /etc/quagga/*


ifconfig eth0:1 172.16.1.1/24
ifconfig eth0:2 172.16.2.1/24

sysctl -w net.ipv4.ip_forward=1

route del default
route del -net 169.254.0.0/16
route del -net 192.168.1.0/24

sudo /etc/init.d/quagga restart
