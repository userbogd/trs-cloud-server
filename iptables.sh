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

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

# Все разрешаем на локальном интерфейсе (для внутренних соединений баз данных и разных сервисов)
iptables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT

# Не трогаем уже установленные соединения
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 1883 -j ACCEPT
iptables -A INPUT -p tcp --dport 8883 -j ACCEPT
iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
iptables -A INPUT -p tcp --dport 18083 -j ACCEPT
iptables -A INPUT -p tcp --dport 20080 -j ACCEPT

# PPP VPN
iptables -A INPUT -i ppp+ -j ACCEPT
iptables -A OUTPUT -o ppp+ -j ACCEPT
# Пропускать входящие соединения на порт 1723 (PPTP)
iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
# Пропускать все пакеты GRE
iptables -A INPUT -p 47 -j ACCEPT
iptables -A OUTPUT -p 47 -j ACCEPT
# Включить форвардинг IP
iptables -F FORWARD
iptables -A FORWARD -j ACCEPT
# Включить NAT для интерфейсов eth0 и ppp*
iptables -A POSTROUTING -t nat -o ens3 -j MASQUERADE
iptables -A POSTROUTING -t nat -o ppp+ -j MASQUERADE

iptables -A INPUT -p udp --dport 60600  -j ACCEPT

#forward port 60600 on ens3  to ip  172.16.0.10 port 60500
iptables -t nat -A PREROUTING -i ens3  -p udp --dport 60600 -j DNAT --to-destination 172.16.0.10:60500

#forward port 60601 on ens3  to ip  172.16.0.20 port 60500
iptables -t nat -A PREROUTING -i ens3  -p udp --dport 60601 -j DNAT --to-destination 172.16.0.20:60500

#PING
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT