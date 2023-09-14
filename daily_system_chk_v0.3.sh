#!/bin/bash

###########################
### make by jindeokyong ###
###########################

## variables
user=jindeokyong
date1=`date +"%F"`
date2=`date +%F -d '7day ago'`
path1=/home/jindeokyong

if [ ! -z "$path1/logs" ] ; then
	mkdir -p $path1/logs
	chown $user. $path1/logs
fi

col1="\033[0;33m"
col2="\033[0;0m"
col3="\033[0;31m"
col4="\033[0;32m"

if grep '\ 7\.' /etc/redhat-release &> /dev/null; then
	export osver1='7'
elif	grep '\ 8\.' /etc/redhat-release &> /dev/null; then
	export osver1='8'
elif	grep '\ 9\.' /etc/redhat-release &> /dev/null; then
	export osver1='9'
fi

chk_sys1 ()
{
echo -e "$col1##############################\n$col2[INFO] OS"
cat /etc/redhat-release
echo -e "$col1##############################\n$col2[INFO] HostName"
echo -e "`hostname`"
echo -e "$col1##############################$col2"
disk1=$(df -h | grep -v -i "boot\|tmpfs\|use" | awk '{print $5}'| cut -d "%" -f 1 | sort -rh | head -1)
disk2="90"
disk3="80"
if [ "${disk1}" -ge "${disk2}" ] ; then
	echo -e "[INFO] Disk (${col3}Critical${col2})"
elif [ "${disk1}" -ge "${disk3}" ] ; then
	echo -e "[INFO] Disk (${col1}Warning${col2})"
else
	echo -e "[INFO] Disk (${col4}Normal${col2})"
fi
df -h
echo -e "$col1##############################\n$col2[INFO] Memory"
free -m
echo -e "$col1##############################\n$col2[INFO] Uptime"
uptime
echo -e "$col1##############################\n$col2[INFO] Selinux"
sestatus
echo -e "$col1##############################\n$col2[INFO] Login IP / 3 head"
last | grep -v "reboot\|tty\|:0\|:1" | head -3
echo -e "$col1##############################\n$col2[INFO] Login Failed / 3 head"
lastb | head -3
echo -e "$col1##############################\n$col2[INFO] Firewalld"
systemctl is-active firewalld
echo -e "$col1##############################\n$col2[INFO] Time"
date
case $(rpm -qa | grep chrony |wc -l) in 
1 ) chronyc sources | grep "\^\*" ;;
* ) ntpq -p |grep "\*" ;;
esac
echo -e "$col1##############################\n$col2[INFO] File Change,Modify Time"
if [ ${osver1} == "7" ] ;then
	files="/etc/fstab /etc/passwd /etc/group /etc/hosts /etc/hosts.allow /var/log/yum.log"
elif [ ${osver1} == "8" ] ; then
	files="/etc/fstab /etc/passwd /etc/group /etc/hosts /etc/hosts.allow /var/log/dnf.log"
elif [ ${osver1} == "9" ] ; then
	files="/etc/fstab /etc/passwd /etc/group /etc/hosts /etc/hosts.allow /var/log/dnf.log"
fi
for i in $files
do
if [ $(stat $i | grep -i "chan" | awk '{print $2}'|awk -F"-" '{print $2}') == $(date +"%F" |awk -F"-" '{print $2}') ] || [ $(stat $i | grep -i "modi" | awk '{print $2}'|awk -F"-" '{print $2}') == $(date +"%F"|awk -F"-" '{print $2}') ]; then
	echo -e "[INFO] $i (${col3}Critical${col2})\n $(stat $i | grep -i "chan\|modi")"
else
	echo -e "[INFO] $i (${col4}Normal${col2})\n $(stat $i | grep -i "chan\|modi")"
fi
done
}

chk_sys1 > $path1/logs/$date1.txt

### Delete
find $path1/logs/ -name "$date2.txt" -exec rm -rf {} \;
