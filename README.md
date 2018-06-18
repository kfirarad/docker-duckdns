# Docker DuckDNS
This image will periodically update the Dynamic DNS with [duckdns.org](https://www.duckdns.org/)

## Environment Variables
The default parameters can be overridden by setting environment variables on the container using the **docker run -e** flag.

 * **DUCKDNS_DOMAIN** - Subdomain/hostname to update, e.g. myhostname.
 * **DUCKDNS_TOKEN** - DuckDNS authentication token copied from duckdns.org -> install -> linux cron, e.g. 1234abcd-abcd-1234-abcd-123456789abc
 * **DUCKDNS_IP** - IP-address to update with. Defaults to the IP-address of the Docker host machine.
 * **DUCKDNS_UPDATE_INTERVAL=600** - Interval in seconds to sleep between updates. Defaults to 1800 seconds = 30 minutes.
 * **DUCKDNS_REMOTE_DETECT_IP** - `false` will let the container determine the
   external IP to be passed to Duck DNS. `true` will skip this logic and let
   Duck DNS determine the IP. (Defaults to `false`.)

## Deployment

### Systemd

Create a [Systemd unit](http://www.freedesktop.org/software/systemd/man/systemd.unit.html) file in **/etc/systemd/system/duckdns.service** with contents like

```
[Unit]
Description=DuckDNS Dynamic DNS updater
After=docker.service
Requires=docker.service

[Install]
WantedBy=multi-user.target

[Service]
Environment=IMAGE=meltwater/duckdns:latest NAME=duckdns

# Allow docker pull to take some time
TimeoutStartSec=600

# Restart on failures
KillMode=none
Restart=always
RestartSec=15

ExecStartPre=-/usr/bin/docker kill $NAME
ExecStartPre=-/usr/bin/docker rm $NAME
ExecStartPre=-/usr/bin/docker pull "${IMAGE}"
ExecStart=/usr/bin/docker run --name $NAME --net=host \
	-e DUCKDNS_DOMAIN=myhostname \
	-e DUCKDNS_TOKEN=1234abcd-abcd-1234-abcd-123456789abc \
	$IMAGE

ExecStop=/usr/bin/docker stop $NAME
```

Then enable and start the unit
```
systemctl daemon-reload
systemctl enable duckdns.service
systemctl start duckdns.service
```

Check status and logs using e.g.
```
systemctl status duckdns.service
journalctl -f duckdns.service
```

### Command Line
```
docker run --net=host \
	-e DUCKDNS_DOMAIN=myhostname \
	-e DUCKDNS_TOKEN=1234abcd-abcd-1234-abcd-123456789abc \
    meltwater/duckdns:latest
```
