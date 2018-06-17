#!/bin/sh
DUCKDNS_UPDATE_INTERVAL=${DUCKDNS_UPDATE_INTERVAL:-1800}
DUCKDNS_REMOTE_DETECT_IP=${DUCKDNS_REMOTE_DETECT_IP:-false}

if [ -z "$DUCKDNS_DOMAIN" ]; then
	echo 'Please supply the $DUCKDNS_DOMAIN environment variable'
	exit 1
fi

if [ -z "$DUCKDNS_TOKEN" ]; then
	echo 'Please supply the $DUCKDNS_TOKEN environment variable'
	exit 1
fi

while true; do
	URL="https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}"
	if [ "$DUCKDNS_REMOTE_DETECT_IP" = "false" ]; then
		MACHINE_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
		IP=${DUCKDNS_IP:-$MACHINE_IP}
		if [ -z "$IP" ]; then
			echo "Failed to find public IP. Is networking up yet?"
			exit 1
		fi

		echo "Using IP: $IP"
		URL="${URL}&ip=${IP}"
	fi

	echo "Calling URL: $URL"
	curl -s -k "$URL" & wait

	# Sleep and loop
	sleep $DUCKDNS_UPDATE_INTERVAL & wait
done
