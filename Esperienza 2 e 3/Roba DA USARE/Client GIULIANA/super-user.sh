#definisco l'indirizzo della mia interfaccia e la mia rete
ifconfig eth0:1 172.16.1.2/24;

#elimino il gw di default
route del default gw 192.168.43.1;
#route del -net 169.254.0.0/16;
#route del -net 192.168.43.0/24;

#definitsco il gw di default
route add default gw 172.16.1.1;

#nc6 172.16.1.3 -p 5000
