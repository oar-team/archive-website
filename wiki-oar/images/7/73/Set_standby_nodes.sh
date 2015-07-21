#!/bin/bash
set -e

# This script is intended to be used from the SCHEDULER_NODE_MANAGER_SLEEP_CMD
# variable of the oar.conf file.
# It halts the nodes given in the stdin, but refuses to stop nodes if this
# results in less than #NODES_KEEP_ALIVE alive nodes, because we generally
# want to have some nodes ready for treating immediately some jobs.

NODES_KEEP_ALIVE=4

NODES=`cat`

ALIVE_NODES=`oarnodes  --sql "state = 'Alive' and network_address NOT IN (SELECT distinct(network_address) FROM resources where resource_id IN (SELECT resource_id  FROM assigned_resources WHERE assigned_resource_index = 'CURRENT'))" | grep '^network_address' | sort -u`

NODES_TO_SHUTDOWN=""

for NODE in $NODES
do
  if [ $ALIVE_NODES -gt $NODES_KEEP_ALIVE ]
  then
    NODES_TO_SHUTDOWN="$NODE\n$NODES_TO_SHUTDOWN"
    let ALIVE_NODES=ALIVE_NODES-1
  else
    echo "Not halting $NODE because I need to keep $NODES_KEEP_ALIVE alive nodes"
  fi
done

if [ "$NODES_TO_SHUTDOWN" != "" ]
then
  echo -e "$NODES_TO_SHUTDOWN" |/usr/lib/oar/sentinelle.pl -f - -t 3 -p '/sbin/halt -p'
fi
