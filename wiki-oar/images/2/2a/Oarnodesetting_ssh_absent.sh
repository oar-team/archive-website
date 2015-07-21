#!/bin/sh
# oarnodesetting_ssh: oarnodesetting SSH wrapper
# $Id: oarnodesetting_ssh 949 2007-10-22 15:44:26Z capitn $
# This script is to be called from the node via SSH so that the server performs 
# the oarnodesetting command and changes the state of the calling node.
#
# NB:
# 1- To get this script working, the oar ressource database table must have a  
# `ip' field containing the IP address for all the nodes
# 2- A dedicated SSH key may be configured to restrict the ssh call capability
# from the nodes to the server, by modifying the authorized_keys of oar on the
# serveur as follows:
# command="/usr/lib/oar/oarnodesetting_ssh" [dediacted pub key info]...
# 
# Warning: if $IP does not exist in the database or every corresponding
#          resource states are 'Dead' then this script will return an exit code
#          of 12 not 0 (this is the default behaviour of "oarnodesetting").

IP=$(echo $SSH_CONNECTION | cut -d " " -f 1 )
OARNODESETTINGCMD=/usr/sbin/oarnodesetting
[ -n "$IP" ] || exit 1
exec $OARNODESETTINGCMD -s Absent --sql "ip = '$IP' AND state != 'Dead'"
exit 1
