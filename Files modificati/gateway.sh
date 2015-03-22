#!/bin/bash
#parameters
super_client="10.16.1.2";
server="10.16.2.2";
alias="1";
network_1="10.16.1";
network_2="10.16.2";
cidr="/24";
OUT_IFACE="eth0";
IN_IFACE="eth0";
# change ip alias
ifconfig ${IN_IFACE}:1 $network_1.$alias$cidr;
ifconfig ${OUT_IFACE}:2 $network_2.$alias$cidr;

#route del default;

#Activate forwarding
sysctl -w net.ipv4.ip_forward=1;
# alternative
#echo "1" > /proc/sys/net/ipv4/ip_forward;

#	PROTOCOL	PORT	SOURCE_IP	MARK
#	tcp		80	$super_client	11
#	all		-	$super_client	12
#	icmp		-	all		21	
#	tcp		80	all		22
#	udp		-	all		23
# 	all		-	all		24
#	all		-	$server		30
###########################################################################################
#
# create qdisc tree
#

#delete previous rules
tc qdisc del dev ${OUT_IFACE} root;

#create tree
tc qdisc add dev ${OUT_IFACE} root handle 1: htb default 24;

#root class
tc class add dev ${OUT_IFACE} parent 1: classid 1:1 htb rate 2mbps ceil 3mbps \
    burst 1mb;
# server class
tc class add dev ${OUT_IFACE} parent 1: classid 1:30 htb rate 1mbps ceil 1.5mbps \
    burst 1mb;

#gold user class
tc class add dev ${OUT_IFACE} parent 1:1 classid 1:10 htb rate 400kbps ceil 600kbps \
    burst 400kb;

#normal user class
tc class add dev ${OUT_IFACE} parent 1:1 classid 1:20 htb rate 150kbps ceil 180kbps \
    burst 80kb;

# web class for gold user
tc class add dev ${OUT_IFACE} parent 1:10 classid 1:11 htb rate 300kbps ceil 450kbps;
tc qdisc add dev ${OUT_IFACE} parent 1:11 handle 11: netem delay 100ms 20ms \
    distribution normal loss 5% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;
#tc qdisc add dev ${OUT_IFACE} parent 1:11 handle 11: netem delay 100ms 20ms \
#    distribution normal loss 5% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;
#other class for gold user
tc class add dev ${OUT_IFACE} parent 1:10 classid 1:12 htb rate 100kbps ceil 150kbps;
#tc class add dev ${OUT_IFACE} parent 1:10 classid 1:12 htb rate 8kbps ceil 10kbps;
tc qdisc add dev ${OUT_IFACE} parent 1:12 handle 12: netem delay 100ms 20ms \
    distribution normal loss 2% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;

#icmp class for normal user
tc class add dev ${OUT_IFACE} parent 1:20 classid 1:21 htb rate 10kbps ceil 15kbps;
tc qdisc add dev ${OUT_IFACE} parent 1:21 handle 21: netem delay 100ms 50ms \
    distribution normal loss 2% duplicate 0.1% corrupt 0.1% reorder 5% 15% gap 5;
# web class for normal user 
tc class add dev ${OUT_IFACE} parent 1:20 classid 1:22 htb rate 70kbps ceil 100kbps;
tc qdisc add dev ${OUT_IFACE} parent 1:22 handle 22: netem delay 500ms 50ms \
    distribution normal loss 30% duplicate 1% corrupt 5% reorder 25% 50%;
#udp class for normal user
tc class add dev ${OUT_IFACE} parent 1:20 classid 1:23 htb rate 50kbps ceil 80kbps;
tc qdisc add dev ${OUT_IFACE} parent 1:23 handle 23: netem delay 500ms 50ms \
    distribution normal loss 30% duplicate 1% corrupt 5% reorder 25% 50%;
#other protocol class for normal
tc class add dev ${OUT_IFACE} parent 1:20 classid 1:24 htb rate 20kbps ceil 35kbps;
tc qdisc add dev ${OUT_IFACE} parent 1:24 handle 24: netem delay 500ms 50ms \
    distribution normal loss 30% duplicate 1% corrupt 5% reorder 25% 50%;

##########################################################################################
#
# add filters 
#
# personal note: from lartc.pdf pag. 67: [...] Also, with HTB, you should attach all filters to the root! [...]

# super client
# 	web
tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 11 fw flowid 1:11;
#	other protocols
tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 12 fw flowid 1:12;

# normal client
# 	icmp
tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 21 fw flowid 1:21;
#	web
tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 22 fw flowid 1:22;
#	udp
tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 23 fw flowid 1:23;
#other protocols
tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 24 fw flowid 1:24;

# server
tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 30 fw flowid 1:30;


###########################################################################################
#
# iptables mangle
#
# delete previous rules
iptables -t mangle -F;
# mark source ip server
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -s ${server} -j MARK --set-mark 30;
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -s ${server} -j RETURN;

# mark packets from super client
#	web
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -s ${super_client} -p tcp --dport 80 -j MARK --set-mark 11;
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -s ${super_client} -p tcp --dport 80 -j RETURN;
#	other protocols
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -s ${super_client} -j MARK --set-mark 12;
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -s ${super_client} -j RETURN;

# mark packets from normal client
# 	icmp
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -p icmp -j MARK --set-mark 21;
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -p icmp -j RETURN;
#	web
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -p tcp --dport 80 -j MARK --set-mark 22;
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -p tcp --dport 80 -j RETURN;
# 	udp
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -p udp -j MARK --set-mark 23;
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -p udp -j RETURN;
# 	other protocols (optional)
iptables -A PREROUTING -t mangle -i ${IN_IFACE} -j MARK --set-mark 24;


