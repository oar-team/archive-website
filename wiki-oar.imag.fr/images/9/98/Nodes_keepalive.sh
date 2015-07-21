#!/bin/bash
set -e

# This script is intended to be ran every 5 minutes from the crontab
# It ensures that #NODES_KEEP_ALIVE nodes with at least 1 free resource
# are always alive and not shut down. It wakes up the nodes by submiting
# a dummy job. It does not submit jobs if all the resources are used or
# not available (cm_availability set to a low value)

NODES_KEEP_ALIVE=4
ADMIN_USER=bzeznik

# Locking
LOCK=/var/lock/`basename $0`
### Locking for Debian (using lockfile-progs):
#lockfile-create $LOCK || exit 1
#lockfile-touch $LOCK &
#BADGER="$!"
### Locking for others (using sendmail lockfile)
lockfile -r3 -l 43200 $LOCK

if [ "`oarstat |grep \"wake_up_.*node\"`" = "" ]
then

 # Get the number of Alive nodes with at least 1 free resource
 ALIVE_NODES=`oarnodes  --sql "state = 'Alive' and network_address NOT IN (SELECT distinct(network_address) FROM resources where resource_id IN (SELECT resource_id  FROM assigned_resources WHERE assigned_resource_index = 'CURRENT'))" | grep '^network_address' | sort -u`
 
 # Get the number of nodes in standby
 let AVAIL_DATE=`date +%s`+3600
 WAKEABLE_NODES=`oarnodes  --sql "state = 'Absent' and cm_availability > $AVAIL_DATE" |grep "^network_address" |sort -u|wc -l`
 
 if [ $ALIVE_NODES -lt $NODES_KEEP_ALIVE ]
 then
   if [ $WAKEABLE_NODES -gt 0 ]
   then
     if [ $NODES_KEEP_ALIVE -gt $WAKEABLE_NODES ]
     then
       NODES_KEEP_ALIVE=$WAKEABLE_NODES
     fi
     su - $ADMIN_USER -c "oarsub -n wake_up_${NODES_KEEP_ALIVE}nodes -l /nodes=${NODES_KEEP_ALIVE}/core=1,walltime=00:00:10 'sleep 1'"
   fi
 fi
fi
 
### Unlocking for Debian:
#kill "${BADGER}"
#lockfile-remove $LOCK
### Unlocking for others:
rm -f $LOCK
