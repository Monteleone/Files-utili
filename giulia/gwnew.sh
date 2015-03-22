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

tc class add dev ${OUT_IFACE} parent 1:10 classid 1:11 htb rate 300kbps ceil 450kbps;
tc qdisc add dev ${OUT_IFACE} parent 1:11 handle 11: netem delay 100ms 20ms \
    distribution normal loss 95% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;

tc class add dev ${OUT_IFACE} parent 1:20 classid 1:21 htb rate 100kbps ceil 150kbps;
tc qdisc add dev ${OUT_IFACE} parent 1:21 handle 21: netem delay 100ms 20ms \
    distribution normal loss 95% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;


tc class add dev ${OUT_IFACE} parent 1:30 classid 1:31 htb rate 100kbps ceil 150kbps;
tc qdisc add dev ${OUT_IFACE} parent 1:31 handle 30: netem delay 100ms 20ms \
    distribution normal loss 95% duplicate 0.1% corrupt 0.5% reorder 5% 15% gap 5;

#################filtri

tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 11 fw flowid 1:11;
#	other protocols


# normal client
# 	icmp
tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 21 fw flowid 1:21;
tc filter add dev ${OUT_IFACE} parent 1: prio 0 protocol ip handle 30 fw flowid 1:30;















