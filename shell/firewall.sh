#!/bin/bash
# author:  Mikael Flood <thernx@gamil.com>
# relies on iptables.
# single Linux box firwall script.

ipt="/sbin/iptables"
EXTIF="eth0"
INTIF="eth1"

# subnets
INTNET=""
DMZ=""
work=""
UNIVERSE="0.0.0.0/0"

# DMZs
NGINX=""
srv_ssh=""

# restore iptables sanity
$ipt -F
$ipt -t nat -F
$ipt -t nat -X
$ipt -t mangle -F
$ipt -t mangle -X
$ipt -t raw -F
$ipt -t raw -X
$ipt -t security -F
$ipt -t security -X
$ipt -X

# Default policy
$ipt --policy INPUT DROP
$ipt --policy OUTPUT DROP
$ipt --policy FORWARD DROP

## Inbound
$ipt -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$ipt -A INPUT -i lo -s $UNIVERSE -d $UNIVERSE -j ACCEPT
$ipt -A INPUT -s $DMZ -p udp -m multiport --dports 25,53,123 -j ACCEPT -m comment --comment "ALLOW 25,53,123 to DMZ"
$ipt -A INPUT -i $INTIF -s $INTNET -j ACCEPT

## Outbound
#$ipt -A OUTPUT -j LOG
$ipt -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$ipt -A OUTPUT -o lo -s $UNIVERSE -d $UNIVERSE -j ACCEPT
$ipt -A OUTPUT -o $EXTIF -p udp -m multiport --dports 25,53,123 -j ACCEPT -m comment --comment "ALLOW 25,53,123 to FW"
$ipt -A OUTPUT -o $EXTIF -p tcp -m multiport --dports 20,21,80,443 -j ACCEPT -m comment --comment "ALLOW 20,21,80,443 to FW"
$ipt -A OUTPUT -o $INTIF -s $INTNET -j ACCEPT
$ipt -A OUTPUT -o $EXTIF -p icmp --icmp-type echo-request -j ACCEPT

## Forward
$ipt -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
$ipt -A FORWARD -s $UNIVERSE -d $UNIVERSE -m state --state INVALID -j DROP
$ipt -A FORWARD -i $EXTIF -s $work -p tcp --dport 22 -m limit --limit 3/m -j ACCEPT
$ipt -A FORWARD -i $EXTIF -p tcp -m multiport --dports https -j ACCEPT
$ipt -A FORWARD -o $EXTIF -p tcp -m multiport --dports 20,21,22,80,443,587,9418,5223,22222:22223,27000:27050,49164 -s $INTNET -j ACCEPT
$ipt -A FORWARD -o $EXTIF -p udp -m multiport --dports 20,21,22,80,443,587,9418,5223,22222:22223,27000:27050,49164 -s $INTNET -j ACCEPT

## NAT
$ipt -t nat -A PREROUTING -i $INTIF -p udp --dport 123 -j DNAT --to-destination 127.0.0.1:123 -m comment --comment "redirect ntp to FW"
$ipt -t nat -A PREROUTING -i $INTIF -s $INTNET -p udp --dport 53 -j DNAT --to-destination 192.168.0.1 -m comment --comment "redirect dns to FW"
$ipt -t nat -A PREROUTING -i $EXTIF -p tcp --dport 22 -j DNAT --to-destination $srv_ssh
$ipt -t nat -A PREROUTING -i $EXTIF -p tcp --dport https -j DNAT --to-destination $NGINX
$ipt -t nat -A POSTROUTING -o $EXTIF -s $INTNET,$DMZ -j MASQUERADE

## DMZ Network
$ipt -A FORWARD -s $INTNET -d $DMZ -j ACCEPT -m comment --comment "Allow INTNET to DMZ"
$ipt -A FORWARD -s $DMZ -d $INTNET -j REJECT -m comment --comment "Deny DMZ to INTNET"
$ipt -A FORWARD -s $DMZ -p tcp -m multiport --dports 25,53,123,80,443 -j ACCEPT -m comment --comment "FORWARD 25,53,123,80,443 to DMZ"
$ipt -A FORWARD -s $DMZ -p udp -m multiport --dports 25,53,123,80,443 -j ACCEPT -m comment --comment "FORWARD 25,53,123,80,443 to DMZ"
