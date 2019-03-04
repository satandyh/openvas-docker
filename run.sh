#!/bin/bash

## two vars for start cantainer
OV_PASSWORD=${OV_PASSWORD:-admin}
PUBLIC_HOSTNAME=${PUBLIC_HOSTNAME:-openvas}
OV_UPDATE=${OV_UPDATE:no}

## Check certs
if [ ! -f /var/lib/openvas/CA/cacert.pem ]; then
	/usr/bin/openvas-manage-certs -a
fi

## start redis server first
/usr/bin/redis-server /etc/redis.conf &

## start openvas system after redis
/usr/sbin/openvassd
/usr/sbin/openvasmd
/usr/sbin/gsad

## Check for users, and create admin
if ! [[ $(openvasmd --get-users) ]] ; then 
	/usr/sbin/openvasmd openvasmd --create-user=admin
	/usr/sbin/openvasmd --user=admin --new-password=$OV_PASSWORD
fi

## set admin pass
if [ -n "$OV_PASSWORD" ]; then
	/usr/sbin/openvasmd --user=admin --new-password=$OV_PASSWORD
fi

## if need to update bases direct after start
if [ "$OV_UPDATE" == "yes" ]; then
	/usr/sbin/greenbone-nvt-sync 
	/usr/sbin/greenbone-certdata-sync 
	/usr/sbin/greenbone-scapdata-sync
fi


