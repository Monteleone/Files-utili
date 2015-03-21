
sudo ifconfig eth0:1 10.16.2.2/24;
sudo route del default
sudo route add default gw 10.16.2.1;


sudo tc qdisc del dev eth0 root;
sudo tc qdisc add dev eth0 root handle 1: htb default 13;
sudo tc class add dev eth0 parent 1:  classid 1:1 htb rate 360kbps ceil 360kbps;
sudo tc class add dev eth0 parent 1:1 classid 1:10 htb rate 150kbps ceil 200kbps;
sudo tc class add dev eth0 parent 1:1 classid 1:11 htb rate 10kbps ceil 15kbps;
sudo tc class add dev eth0 parent 1:1 classid 1:12 htb rate 100kbps ceil 150kbps;
sudo tc class add dev eth0 parent 1:1 classid 1:13 htb rate 100kbps ceil 180kbps;

sudo tc filter add dev eth0 parent 1:0 prio 0 protocol ip handle 10 fw flowid 1:10;
sudo tc filter add dev eth0 parent 1:0 prio 1 protocol ip handle 11 fw flowid 1:11;
sudo tc filter add dev eth0 parent 1:0 prio 2 protocol ip handle 12 fw flowid 1:12;


sudo iptables -t mangle -F;
sudo iptables -A OUTPUT -t mangle -p tcp --sport 80 -j MARK --set-mark 10;
sudo iptables -A OUTPUT -t mangle -p icmp -j MARK --set-mark 11;
sudo iptables -A OUTPUT -t mangle -p udp  -j MARK --set-mark 12;

