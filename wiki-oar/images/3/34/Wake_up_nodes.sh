#!/bin/bash

IPMI_HOST="admin"
POWER_ON_CMD="cpower --up --quiet"

NODES=`cat`

for NODE in $NODES
do
  ssh $IPMI_HOST $POWER_ON_CMD $NODE
done
