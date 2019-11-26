#!/usr/bin/env bash

## two vars for start container
OV_PASSWORD=${OV_PASSWORD:-admin}
OV_UPDATE=${OV_UPDATE:-no}

## Check certs
if [ ! -f /var/lib/openvas/CA/cacert.pem ]; then
	openvas-manage-certs -a
fi

## start redis server first
redis-server /etc/redis.conf --daemonize yes

## redis check
CHECK="$(redis-cli -s /tmp/redis.sock ping)"
while [ "${CHECK}" != "PONG" ]; do
	sleep 1
	CHECK="$(redis-cli -s /tmp/redis.sock ping)"
done

## start openvas system after redis
openvassd
openvasmd --listen=0.0.0.0 --port=9390 --database=/var/lib/openvas/mgr/tasks.db --max-ips-per-target=65536

## Check for users, and create admin
if ! [[ $(openvasmd --get-users) ]]; then
	openvasmd --create-user=admin --role=Admin
	openvasmd --user=admin --new-password=$OV_PASSWORD
fi

## set admin pass
if [ -n "$OV_PASSWORD" ]; then
	openvasmd --user=admin --new-password=$OV_PASSWORD
fi

## if need to update bases direct after start
if [ "$OV_UPDATE" == "yes" ]; then
	greenbone-nvt-sync
	greenbone-certdata-sync
	greenbone-scapdata-sync
	openvasmd --rebuild
fi

## after all start good do start cron daemon
## for periodical update nvt feed db
crond

## start tail for properly working stop and start docker container
tail -F /var/log/openvas/*
