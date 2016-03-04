#!/bin/sh
# init.sh - GNS3 specific docker initialization

# configure eth interfaces
sed -n 's/^ *\(eth[0-9]*\):.*/\1/p' < /proc/net/dev | while read dev; do
	eval ip=\$IP_$dev
	[ -n "$ip" ] && ip -family inet address add $ip dev $dev
	eval ip=\$IPv6_$dev
	[ -n "$ip" ] && ip -family inet6 address add $ip dev $dev
done

# IP routes
[ -n "$IP_default_gw" ] && \
	ip -family inet route add default via $IP_default_gw
for i in "" 0 1 2 3 4 5 6 7 8 9; do
	eval route=\$IP_route$i
	net=${route%% *}
	dest=${route#* } ; dest=${dest%% *}
	[ -n "$dest" ] && ip -family inet route add $net via $dest
done

# IPv6 routes
[ -n "$IPv6_default_gw" ] && \
	ip -family inet6 route add default via $IPv6_default_gw
for i in "" 0 1 2 3 4 5 6 7 8 9; do
	eval route=\$IPv6_route$i
	net=${route%% *}
	dest=${route#* } ; dest=${dest%% *}
	[ -n "$dest" ] && ip -family inet6 route add $net via $dest
done

# continue normal docker startup
exec "$@"
