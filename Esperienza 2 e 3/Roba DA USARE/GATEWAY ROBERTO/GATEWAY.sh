echo "TERZA PROVA"
echo "1 setup and mangle"
echo "2 all green"
echo "3 packet lost Super"
echo "4 duplicazione Super "
echo "5 corruzione normal user"
echo "6 delay normal"
echo "7 reorder normal"
echo "" 
echo "Utilities:"
echo "netcatudp"
echo "netcattcp"
echo "exit"

echo "nb. iptables -L -t mangle -n -v"
read sel

if [ $sel = "1" ]; then
	#SETUP
	super_client="172.16.1.2"
	server="172.16.2.2"
	alias="1"
	network_1="172.16.1"
	network_2="172.16.2"
	cidr="/24"
	OUT_IFACE="wlan0"
	IN_IFACE="wlan0"
	# change ip alias
	ifconfig ${IN_IFACE}:1 $network_1.$alias$cidr;
	ifconfig ${OUT_IFACE}:2 $network_2.$alias$cidr;
	echo "1" > /proc/sys/net/ipv4/ip_forward;
	echo "Forwarding on"ip
	#Disable ICMP redirects
	#all
	sysctl -w net.ipv4.conf.all.accept_redirects=0
	sysctl -w net.ipv4.conf.all.send_redirects=0
	#default
	sysctl -w net.ipv4.conf.default.accept_redirects=0
	sysctl -w net.ipv4.conf.default.send_redirects=0
	#wlan0
	sysctl -w net.ipv4.conf.wlan0.accept_redirects=0
	sysctl -w net.ipv4.conf.wlan0.send_redirects=0
	#lo
	sysctl -w net.ipv4.conf.lo.accept_redirects=0
	sysctl -w net.ipv4.conf.lo.send_redirects=0
	#wlan0
	sysctl -w net.ipv4.conf.wlan0.accept_redirects=0
	sysctl -w net.ipv4.conf.wlan0.send_redirects=0	
	iptables -A PREROUTING -t mangle -i wlan0 -s 172.16.1.3 -j MARK --set-mark 21;
	iptables -A PREROUTING -t mangle -i wlan0 -s 172.16.1.3 -j RETURN;
	iptables -A PREROUTING -t mangle -i wlan0 -s 172.16.2.2 -j MARK --set-mark 30;
	iptables -A PREROUTING -t mangle -i wlan0 -s 172.16.2.2 -j RETURN;
	iptables -A PREROUTING -t mangle -i wlan0 -p icmp -j MARK --set-mark 11;
	iptables -A PREROUTING -t mangle -i wlan0 -p icmp -j RETURN;
	echo "172.16.1.3 marked as superuser (21)"
	echo "172.16.2.2 marked as server (30)"
	echo "others marked as normal (11)" 
	echo "server ip 172.16.2.2"
fi
if [ $sel = "2" ]; then
	OUT_IFACE="wlan0";
	IN_IFACE="wlan0";
	#delete previous rules
		tc qdisc del dev ${OUT_IFACE} root;
	#create tree
		tc qdisc add dev ${OUT_IFACE} root handle 1: htb default 30;
	#root class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:1 htb rate 2mbps ceil 3mbps \
		burst 1mb;
	#gold user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:10 htb rate 400kbps ceil 600kbps \
	 	burst 400kb;
	#normal user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:20 htb rate 150kbps ceil 180kbps \
	 	   burst 80kb;
	# server class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:30 htb rate 1mbps ceil 1.5mbps \
	  	  burst 1mb;
	#others	
		tc class add dev ${OUT_IFACE} parent 1:10 classid 1:11 htb rate 300kbps ceil 450kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:11 handle 11: netem delay 1ms 1ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.1% reorder 5% 15% gap 5;
	#super user
		tc class add dev ${OUT_IFACE} parent 1:20 classid 1:21 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:21 handle 21: netem delay 1ms 20ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.1% reorder 5% 15% gap 5;
		tc class add dev ${OUT_IFACE} parent 1:30 classid 1:31 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:31 handle 30: netem delay 1ms 20ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;
	################filtri
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 11 fw flowid 1:11;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 21 fw flowid 1:21;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 30 fw flowid 1:30;
		echo "ALL GREEN!"
fi
if [ $sel = "3" ]; then
	OUT_IFACE="wlan0";
	IN_IFACE="wlan0";
	#delete previous rules
		tc qdisc del dev ${OUT_IFACE} root;
	#create tree
		tc qdisc add dev ${OUT_IFACE} root handle 1: htb default 30;
	#root class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:1 htb rate 2mbps ceil 3mbps \
		burst 1mb;
	#gold user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:10 htb rate 400kbps ceil 600kbps \
	 	burst 400kb;
	#normal user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:20 htb rate 150kbps ceil 180kbps \
	 	   burst 80kb;

	# server class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:30 htb rate 1mbps ceil 1.5mbps \
	  	  burst 1mb;
	#others	
		tc class add dev ${OUT_IFACE} parent 1:10 classid 1:11 htb rate 300kbps ceil 450kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:11 handle 11: netem delay 1ms 1ms \
		    distribution normal loss 70% duplicate 0.1% corrupt 0.1% reorder 5% 15% gap 5;
	#super user
		tc class add dev ${OUT_IFACE} parent 1:20 classid 1:21 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:21 handle 21: netem delay 1ms 20ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.1% reorder 5% 15% gap 5;
	#server
		tc class add dev ${OUT_IFACE} parent 1:30 classid 1:31 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:31 handle 30: netem delay 1ms 20ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;
	################filtri
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 11 fw flowid 1:11;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 21 fw flowid 1:21;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 30 fw flowid 1:30;
	echo "Rete manomessa configurazione 3"
fi
if [ $sel = "4" ]; then
	OUT_IFACE="wlan0";
	IN_IFACE="wlan0";
	#delete previous rules
		tc qdisc del dev ${OUT_IFACE} root;
	#create tree
		tc qdisc add dev ${OUT_IFACE} root handle 1: htb default 30;
	#root class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:1 htb rate 2mbps ceil 3mbps \
		burst 1mb;
	#gold user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:10 htb rate 400kbps ceil 600kbps \
	 	burst 400kb;
	#normal user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:20 htb rate 150kbps ceil 180kbps \
	 	   burst 80kb;

	# server class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:30 htb rate 1mbps ceil 1.5mbps \
	  	  burst 1mb;
	#surder
		tc class add dev ${OUT_IFACE} parent 1:10 classid 1:11 htb rate 300kbps ceil 450kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:11 handle 11: netem delay 1ms 1ms \
		    distribution normal loss 1% duplicate 400% corrupt 0.1% reorder 5% 15% gap 5;
	#normal
		tc class add dev ${OUT_IFACE} parent 1:20 classid 1:21 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:21 handle 21: netem delay 1ms 229ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.1% reorder 5% 15% gap 5;
	#server
		tc class add dev ${OUT_IFACE} parent 1:30 classid 1:31 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:31 handle 30: netem delay 1ms 20ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;
	################filtri
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 11 fw flowid 1:11;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 21 fw flowid 1:21;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 30 fw flowid 1:30;
	echo "rete manomessa configurazione 4"
fi
if [ $sel = "5" ]; then
	OUT_IFACE="wlan0";
	IN_IFACE="wlan0";
	#delete previous rules
		tc qdisc del dev ${OUT_IFACE} root;
	#create tree
		tc qdisc add dev ${OUT_IFACE} root handle 1: htb default 30;
	#root class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:1 htb rate 2mbps ceil 3mbps \
		burst 1mb;
	#gold user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:10 htb rate 400kbps ceil 600kbps \
	 	burst 400kb;
	#normal user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:20 htb rate 150kbps ceil 180kbps \
	 	   burst 80kb;

	# server class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:30 htb rate 1mbps ceil 1.5mbps \
	  	  burst 1mb;
	#super
		tc class add dev ${OUT_IFACE} parent 1:10 classid 1:11 htb rate 300kbps ceil 450kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:11 handle 11: netem delay 1ms 1ms \
		    distribution normal loss 1% duplicate 1% corrupt 0.1% reorder 5% 15% gap 5;
	#normal
		tc class add dev ${OUT_IFACE} parent 1:20 classid 1:21 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:21 handle 21: netem delay 1ms 1ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 80% reorder 5% 15% gap 5;
	#server
		tc class add dev ${OUT_IFACE} parent 1:30 classid 1:31 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:31 handle 30: netem delay 1ms 20ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;
	################filtri
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 11 fw flowid 1:11;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 21 fw flowid 1:21;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 30 fw flowid 1:30;
	echo "rete manomessa configurazione 5"
fi
if [ $sel = "6" ]; then
	OUT_IFACE="wlan0";
	IN_IFACE="wlan0";
	#delete previous rules
		tc qdisc del dev ${OUT_IFACE} root;
	#create tree
		tc qdisc add dev ${OUT_IFACE} root handle 1: htb default 30;
	#root class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:1 htb rate 2mbps ceil 3mbps \
		burst 1mb;
	#gold user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:10 htb rate 400kbps ceil 600kbps \
	 	burst 400kb;
	#normal user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:20 htb rate 150kbps ceil 180kbps \
	 	   burst 80kb;

	# server class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:30 htb rate 1mbps ceil 1.5mbps \
	  	  burst 1mb;
	#super
		tc class add dev ${OUT_IFACE} parent 1:10 classid 1:11 htb rate 300kbps ceil 450kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:11 handle 11: netem delay 1ms 1ms \
		    distribution normal loss 1% duplicate 1% corrupt 0.1% reorder 5% 15% gap 5;
	#normal
		tc class add dev ${OUT_IFACE} parent 1:20 classid 1:21 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:21 handle 21: netem delay 499ms 1ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.1% reorder 1% 15% gap 5;
	#server
		tc class add dev ${OUT_IFACE} parent 1:30 classid 1:31 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:31 handle 30: netem delay 1ms 20ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;
	################filtri
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 11 fw flowid 1:11;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 21 fw flowid 1:21;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 30 fw flowid 1:30;
	echo "rete manomessa configurazione 6"
fi
if [ $sel = "7" ]; then
	OUT_IFACE="wlan0";
	IN_IFACE="wlan0";
	#delete previous rules
		tc qdisc del dev ${OUT_IFACE} root;
	#create tree
		tc qdisc add dev ${OUT_IFACE} root handle 1: htb default 30;
	#root class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:1 htb rate 2mbps ceil 3mbps \
		burst 1mb;
	#gold user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:10 htb rate 400kbps ceil 600kbps \
	 	burst 400kb;
	#normal user class
		tc class add dev ${OUT_IFACE} parent 1:1 classid 1:20 htb rate 150kbps ceil 180kbps \
	 	   burst 80kb;

	# server class
		tc class add dev ${OUT_IFACE} parent 1: classid 1:30 htb rate 1mbps ceil 1.5mbps \
	  	  burst 1mb;
	#super
		tc class add dev ${OUT_IFACE} parent 1:10 classid 1:11 htb rate 300kbps ceil 450kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:11 handle 11: netem delay 1ms 1ms \
		    distribution normal loss 1% duplicate 1% corrupt 0.1% reorder 5% 15% gap 5;
	#normal
		tc class add dev ${OUT_IFACE} parent 1:20 classid 1:21 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:21 handle 21: netem delay 1ms 1ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.1% reorder 50% 15% gap 5;
	#server
		tc class add dev ${OUT_IFACE} parent 1:30 classid 1:31 htb rate 100kbps ceil 150kbps;
		tc qdisc add dev ${OUT_IFACE} parent 1:31 handle 30: netem delay 1ms 20ms \
		    distribution normal loss 1% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;
	################filtri
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 11 fw flowid 1:11;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 21 fw flowid 1:21;
		tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 30 fw flowid 1:30;
	echo "rete manomessa configurazione 7"
fi

if [ $sel = "netcatudp" ]; then
	nc6 -u -l -p 5000 #ascolto udp
fi
if [ $sel = "netcattcp" ]; then
	nc6 -l -p 5000 #ascolto udp
fi

