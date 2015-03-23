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

#wlan0
#sysctl -w net.ipv4.conf.wlan0.accept_redirects=0
#sysctl -w net.ipv4.conf.wlan0.send_redirects=0
