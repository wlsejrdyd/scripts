#!/bin/bash

bann ()
{ echo -e "## Make by. jindeokyong ##\n[INFO] Sub Domain IP LIST\n1. sub1 : 1.1.1.1\n2. sub2 : 2.2.2.2\n3. sub3 : 3.3.3.3\n4. sub4 : 4.4.4.4\n\n[INFO] HIS DR IP LIST\n1. sub1 : 5.5.5.5\n2. sub2 : 6.6.6.6\n3. sub3 : 7.7.7.7\n4. sub4 : 8.8.8.8
\n\033[0;31m## [WARNING] Delete existing records and add new records. ##\033[0m"
}
bann

todo ()
{
echo -e "[INFO] zone file backed up here : $dir1/bak/$tm1/${file1}_${tm2}"
sudo cp -ar $dir1/$file1 $dir1/bak/$tm1/${file1}_${tm2}
echo -e "[OK] subdns IP change of $var1 , $var2 , $var3 , $var4 completed."
sudo sed -i '/sub1\|sub4\|sub2\|sub3/d' $dir1/$file1
}

### Variables
var1="sub1"
var2="sub2"
var3="sub3"
var4="sub4"
dir1="/var/named"
tm1=`date +"%Y%m%d"`
tm2=`date +"%Y%m%d%H%M"`
tm3=`date +"%Y%m%d" -d '90days ago'`
dns1="deok.kr"
file1="${dns1}.zone"
if [ ! -d "$dir1/bak/$tm1" ]; then
	sudo mkdir -p $dir1/bak/$tm1
fi
### Zone File Edit
echo -e "\033[0;32m[Select]\n\033[0;33m1. Service system -> DR\n2. DR -> Service system \n3. Cancel \033[0m"
read read1
case "$read1" in 1 )
todo
sudo echo "sub1                  IN A            5.5.5.5   ;
sub2                  IN A            6.6.6.6   ;
sub3               IN A            7.7.7.7   ;
sub4                  IN A            8.8.8.8   ;" >> $dir1/$file1
;;
2 )
todo
sudo echo "sub1                  IN A            1.1.1.1    ;
sub2                  IN A            2.2.2.2     ;
sub3               IN A            3.3.3.3    ;
sub4                  IN A            4.4.4.4    ;" >> $dir1/$file1
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
sudo sed -i "s@${yyyymmdd}@${newdate1}@g" ${dir1}/${file1}
named-checkzone snuh.org $dir1/$file1
if [ "$?" == "0" ]; then
	sudo systemctl reload named
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
