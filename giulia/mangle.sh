
iptables -A PREROUTING -t mangle -i wlan0 -p icmp -j MARK --set-mark 21;
iptables -A PREROUTING -t mangle -i wlan0 -p icmp -j RETURN;

iptables -A PREROUTING -t mangle -i wlan0 -s 172.16.1.3 -j MARK --set-mark 21;
iptables -A PREROUTING -t mangle -i wlan0 -s 172.16.1.3 -j RETURN;

iptables -A PREROUTING -t mangle -i wlan0 -s 172.16.2.2 -j MARK --set-mark 30;
iptables -A PREROUTING -t mangle -i wlan0 -s 172.16.2.2 -j RETURN;
