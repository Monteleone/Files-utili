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


ifconfig eth0:1 172.16.1.3/24
route add default gw 172.16.1.1
route del default gw 192.168.43.1
