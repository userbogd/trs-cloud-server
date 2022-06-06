#!/bin/sh    
#
# Flush all current rules from iptables
#

#INET_ADAPTER="ens3"

iptables -t filter -F
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -t filter -X
iptables -t nat -X
iptables -t mangle -X
iptables -X

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT


#forward port 60600 on ens3  to ip  172.16.0.10 port 60500
iptables -t nat -A PREROUTING -i ens3  -p udp --dport 60600 -j DNAT --to-destination 172.16.0.10:60500

#forward port 60601 on ens3  to ip  172.16.0.20 port 60500
iptables -t nat -A PREROUTING -i ens3  -p udp --dport 60601 -j DNAT --to-destination 172.16.0.20:60500

#PING
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT