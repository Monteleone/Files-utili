ifconfig wlan0:1 172.16.2.2/24;
route del default
route add default gw 172.16.2.1


tc qdisc del dev wlan0 root
tc qdisc add dev wlan0 root handle 1: htb default 13
tc class add dev wlan0 parent 1:  classid 1:1 htb rate 360kbps ceil 360kbps
tc class add dev wlan0 parent 1:1 classid 1:10 htb rate 150kbps ceil 200kbps
tc class add dev wlan0 parent 1:1 classid 1:11 htb rate 10kbps ceil 15kbps
tc class add dev wlan0 parent 1:1 classid 1:12 htb rate 100kbps ceil 150kbps
tc class add dev wlan0 parent 1:1 classid 1:13 htb rate 100kbps ceil 180kbps

tc filter add dev wlan0 parent 1:0 prio 0 protocol ip handle 10 fw flowid 1:10
tc filter add dev wlan0 parent 1:0 prio 1 protocol ip handle 11 fw flowid 1:11
tc filter add dev wlan0 parent 1:0 prio 2 protocol ip handle 12 fw flowid 1:12
#andato


iptables -t mangle -F
iptables -A OUTPUT -t mangle -p tcp --sport 80 -j MARK --set-mark 10
iptables -A OUTPUT -t mangle -p icmp -j MARK --set-mark 11
iptables -A OUTPUT -t mangle -p udp  -j MARK --set-mark 12

