#!/bin/bash

## Make by. jindeokyong ##

### Variables
dir1="/var/named"
tm1=`date +"%Y%m%d"`
dns1="DNS"
var1=`ping -c1 svc1.${dns1}|head -2|xargs -I{} date '+%F %T{}'  && ping -c1 svc3.${dns1}|head -2|xargs -I{} date '+%F %T{}' && ping -c1 svc2.${dns1} |head -2|xargs -I{} date '+%F %T{}' && ping -c1 svc4.${dns1} |head -2|xargs -I{} date '+%F %T{}'`
dom1="svc1.${dns1} svc2.${dns1} svc3.${dns1} svc4.${dns1}"

default_ping=$1
case $default_ping in 
pingchk )
echo -e "[INFO] check IP.\n$var1"
;;
* )
exit
;;
esac
