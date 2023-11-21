#!/bin/bash

## Make by. jindeokyong ##

### Variables
dir1="/var/named"
tm1=`date +"%Y%m%d"`
#tm2=`date +"%Y%m%d%H%M"`
tm3=`date +"%Y%m%d" -d '7days ago'`
var1=`ping -c1 hisapp.deok.kr|head -2|xargs -I{} date '+%F %T{}'  && ping -c1 hisweb.deok.kr|head -2|xargs -I{} date '+%F %T{}' && ping -c1 hisimg.deok.kr |head -2|xargs -I{} date '+%F %T{}' && ping -c1 hisreport.deok.kr |head -2|xargs -I{} date '+%F %T{}'`
dom1="hisapp.deok.kr hisimg.deok.kr hisweb.deok.kr hisreport.deok.kr"

### Ping check
for i in $dom1
do
ping -c1 $i| xargs -I{} date '+%F %T{}' >> /tmp/ping.log_$tm1
done

default_ping=$1
case $default_ping in 
pingchk )
echo -e "[INFO] check IP.\n$var1"
;;
* )
exit
;;
esac

### Delete
#find $dir1/bak/* -type d -name "$tm3" -exec rm -rf {} \;
