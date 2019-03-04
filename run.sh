#!/bin/bash

OV_PASSWORD=${OV_PASSWORD:-admin}
PUBLIC_HOSTNAME=${PUBLIC_HOSTNAME:-openvas}

## start redis server first
/usr/bin/redis-server

## start openvas system
/usr/sbin/openvassd
/usr/sbin/openvasmd
/usr/sbin/gsad



# Check for users, and create admin
if ! [[ $(openvasmd --get-users) ]] ; then 
	/usr/sbin/openvasmd openvasmd --create-user=admin
	/usr/sbin/openvasmd --user=admin --new-password=$OV_PASSWORD
fi

if [ -n "$OV_PASSWORD" ]; then
	echo "Setting admin password"
	/usr/sbin/openvasmd --user=admin --new-password=$OV_PASSWORD
fi



