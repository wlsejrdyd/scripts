#!/bin/bash

bann ()
{ echo -e "## Make by. jindeokyong ##\n[INFO] HIS IP LIST\n1. hisapp : 1.1.1.1\n2. hisimg : 2.2.2.2\n3. hisreport : 3.3.3.3\n4. hisweb : 4.4.4.4\n\n[INFO] HIS DR IP LIST\n1. hisapp : 5.5.5.5\n2. hisimg : 6.6.6.6\n3. hisreport : 7.7.7.7\n4. hisweb : 8.8.8.8
\n\033[0;31m## [WARNING] Delete existing records and add new records. ##\033[0m"
}
bann

todo ()
{
echo -e "[INFO] zone file backed up here : $dir1/bak/$tm1/${file1}_${tm2}"
cp -ar $dir1/$file1 $dir1/bak/$tm1/${file1}_${tm2}
echo -e "[OK] subdns IP change of $var1 , $var2 , $var3 , $var4 completed."
sed -i '/hisapp\|hisweb\|hisimg\|hisreport/d' $dir1/$file1
}

### Variables
var1="hisweb"
var2="hisapp"
var3="hisimg"
var4="hisreport"
dir1="/var/named"
tm1=`date +"%Y%m%d"`
tm2=`date +"%Y%m%d%H%M"`
tm3=`date +"%Y%m%d" -d '90days ago'`
file1="snuh.org.zone"
if [ ! -d "$dir1/bak/$tm1" ]; then
	mkdir -p $dir1/bak/$tm1
fi
### Zone File Edit
echo -e "\033[0;32m[Select]\n\033[0;33m1. HIS -> DR\n2. DR -> HIS\n3. Cancel \033[0m"
read read1
case "$read1" in 1 )
todo
echo "hisapp                  IN A            5.5.5.5   ; HIS App DR Service,Jung Hyun Chul, T.4068, DATE 220610
hisimg                  IN A            6.6.6.6   ; DR HIS Image Web Service, Jung Hyun Chul, T.4068, DATE 220610
hisreport               IN A            7.7.7.7   ; DR HIS Report Service, Jung Hyun Chul, T.4068, DATE 220610
hisweb                  IN A            8.8.8.8   ; DR HIS Integration Web Service, Jung Hyun Chul, T.4068, DATE 220610" >> $dir1/$file1
;;
2 )
todo
echo "hisapp                  IN A            1.1.1.1    ; HIS App Service, Moon Gui Sun, T.4339, DATE 160627
hisimg                  IN A            2.2.2.2     ; HIS Image Web Service, Moon Gui Sun, T.4339, DATE 160627
hisreport               IN A            3.3.3.3    ; HIS Report Service, Moon Gui Sun, T.4339, DATE 160627
hisweb                  IN A            4.4.4.4    ; HIS Integration Web Service, Moon Gui Sun, T.4339, DATE 160627" >> $dir1/$file1
;;
* | 3 )
exit
;;
esac

### DNS Reload
read -p "[Warning] reload the named service right now ? (y/n) : " read2
case "$read2" in y | Y | yes | YES )
echo -e "[INFO] zone file check result"
date=$(grep -i serial ${dir1}/${file1} | sed 's/^ *\(.*\) *;*$/\1/' |cut -d ";" -f -1)
#xx=$(echo $date | sed 's/*\(..\)/\1/')
#yyyymmdd=$(echo $date | sed 's/\(..\)$//')
yyyymmdd=$(echo $date | sed 's/\(..\)/\1/')
newdate1=$(echo $yyyymmdd | sed "s@${yyyymmdd}@$(date +%Y%m%d%M)@g")
sed -i "s@${yyyymmdd}@${newdate1}@g" ${dir1}/${file1}
named-checkzone snuh.org $dir1/$file1
if [ "$?" == "0" ]; then
	systemctl reload named
	echo "[OK] named service reload complete, please wait 10 second."
	sleep 10
	sudo sh /home/jindeokyong/statchk.sh pingchk
	else
	echo "[Failed] please check the zone file."
fi
;;
* | n | N | no | NO )
echo "don't for got reload named service."
exit
;;
esac

### Delete
#find $dir1/bak/* -type d -name "$tm3" -exec rm -rf {} \;
