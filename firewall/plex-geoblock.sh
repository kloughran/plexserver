#!/usr/bin/env bash
# Usage: sudo plex-geoblock            (apply or refresh; plex-geoblock.timer runs it hourly)
#        sudo plex-geoblock --remove   (delete the rule and the set)
# Drops new connections to Plex (172.30.0.0/24:32400) unless the source is a private
# address or is in one of the COUNTRIES lists from ipdeny.com.
set -euo pipefail

COUNTRIES="${COUNTRIES:-us}"
SET="plex-geo-allow"
SUBNET="172.30.0.0/24"
PORT=32400
CACHE_DIR="${CACHE_DIR:-/var/lib/plex-geoblock}"
MAX_AGE_DAYS=7
URL="https://www.ipdeny.com/ipblocks/data/aggregated"
RULE=(-d "$SUBNET" -p tcp --dport "$PORT" -m conntrack --ctstate NEW -m set ! --match-set "$SET" src -j DROP)

fail() { echo "ERROR: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || fail "run with sudo"
command -v ipset >/dev/null || fail "ipset is not installed: apt install ipset"

if [ "${1:-}" = "--remove" ]; then
	while iptables -C DOCKER-USER "${RULE[@]}" 2>/dev/null; do
		iptables -D DOCKER-USER "${RULE[@]}"
	done
	ipset destroy "$SET" 2>/dev/null || true
	echo "Removed the Plex country block. Port $PORT is open to all sources."
	exit 0
fi

mkdir -p "$CACHE_DIR"

for cc in $COUNTRIES; do
	zone="$CACHE_DIR/$cc.zone"
	[ -n "$(find "$zone" -mtime -"$MAX_AGE_DAYS" 2>/dev/null)" ] && continue
	if curl -fsS -m 60 -o "$zone.new" "$URL/$cc-aggregated.zone" \
		&& [ -s "$zone.new" ] \
		&& ! grep -qvE '^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]{1,2}$' "$zone.new"; then
		mv "$zone.new" "$zone"
		echo "Downloaded $cc: $(wc -l < "$zone") ranges"
	else
		rm -f "$zone.new"
		[ -f "$zone" ] || fail "no list for '$cc' and the download failed; the block was not applied"
		echo "WARNING: could not refresh $cc; using the cached list from $(date -r "$zone" +%F)" >&2
	fi
done

tmp="$SET-tmp"
{
	echo "create $tmp hash:net family inet maxelem 262144"
	for net in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16; do
		echo "add $tmp $net"
	done
	for cc in $COUNTRIES; do
		sed "s|^|add $tmp |" "$CACHE_DIR/$cc.zone"
	done
} | ipset restore -exist

ipset create "$SET" hash:net family inet maxelem 262144 -exist
ipset swap "$tmp" "$SET"
ipset destroy "$tmp"

iptables -C DOCKER-USER "${RULE[@]}" 2>/dev/null || iptables -I DOCKER-USER 1 "${RULE[@]}"

entries=$(ipset list "$SET" -t | awk '/^Number of entries/ {print $NF}')
echo "Plex country block is active: $entries ranges allowed ($COUNTRIES + private)."
