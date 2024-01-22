#!/bin/bash

bann ()
{ echo -e "## Make by. jindeokyong ##\n[INFO] HIS IP LIST\n1. svc1 : 1.1.1.1\n2. svc2 : 2.2.2.2\n3. svc3 : 3.3.3.3\n4. svc4 : 4.4.4.4\n\n[INFO] HIS DR IP LIST\n1. svc1 : 5.5.5.5\n2. svc2 : 6.6.6.6\n3. svc3 : 7.7.7.7\n4. svc4 : 8.8.8.8
\n\033[0;31m## [WARNING] Delete existing records and add new records. ##\033[0m"
}
bann

todo ()
{
echo -e "[INFO] zone file backed up here : ${dir1}/bak/${tm1}/${file1}_${tm2}"
sudo cp -ar ${dir1}/${file1} ${dir1}/bak/${tm1}/${file1}_${tm2}
echo -e "[OK] subdns IP change of ${var1} , ${var2} , ${var3} , ${var4} completed."
sudo sed -i '/^svc1\|^svc4\|^svc2\|^svc3/d' ${dir1}/${file1}
}

dnsreload ()
{
if [ "$?" == "0" ] ;then
	echo "[Warning] reload the named service right now."
	date=$(grep -i serial ${dir1}/${file1} | sed 's/^ *\(.*\) *;*$/\1/' |cut -d ";" -f -1)
	yyyymmdd=$(echo $date | sed 's/\(..\)/\1/')
	xx1=${yyyymmdd:8}
	if [ ${xx1} -lt 5 ] ; then
		xx1=$((xx1 + 1))
		newdate1=$(echo $yyyymmdd | sed "s@${yyyymmdd}@$(date +%Y%m%d)0${xx1}@g")
		sudo sed -i "s@${yyyymmdd}@${newdate1}@g" ${dir1}/${file1}
	else
		xx1=00
		newdate1=$(echo $yyyymmdd | sed "s@${yyyymmdd}@$(date +%Y%m%d)${xx1}@g")
		sudo sed -i "s@${yyyymmdd}@${newdate1}@g" ${dir1}/${file1}
	fi
		if [ "$?" == "0" ]; then
			#sudo systemctl reload named
			echo "[OK] named service reload complete, please wait second."
			sleep 3
			sudo sh /home/jindeokyong/statchk_v1.2.sh pingchk
		else
			echo "[Failed] please check the zone file."
		fi
else
	echo "[Failed] caonnt edited zone file."
	exit 1
fi

find $dir1/bak/* -type d -name "$tm3" -exec rm -rf {} \;
}

### Variables
var1="svc4"
var2="svc1"
var3="svc2"
var4="svc3"
dir1="/var/named"
tm1=`date +"%Y%m%d"`
tm2=`date +"%Y%m%d%H%M"`
tm3=`date +"%Y%m%d" -d '90days ago'`
dns1="DNS"
file1="${dns1}.zone"
if [ ! -d "$dir1/bak/$tm1" ]; then
	sudo mkdir -p $dir1/bak/$tm1
fi
### Zone File Edit
echo -e "\033[0;32m[Select]\n\033[0;33m(HIS or his). HIS -> DR\n(DR or dr). DR -> HIS\n3. Cancel \033[0m"
localselect="$1"
case ${localselect} in
DR | dr )
todo
sudo echo "${var1}			IN A            5.5.5.5
${var2}			IN A            6.6.6.6
${var3}			IN A            7.7.7.7
${var4}			IN A            8.8.8.8" >> $dir1/$file1
dnsreload
;;
HIS | his )
todo
sudo echo "${var1}			IN A            1.1.1.1
${var2}			IN A            2.2.2.2
${var3}			IN A            3.3.3.3
${var4}			IN A            4.4.4.4" >> $dir1/$file1
dnsreload
;;
* )
exit
;;
esac
