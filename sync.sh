#!/bin/bash
# pid 생성 을 해서 중복실행을 방지하는 코드 - made by Enteroa (san0123a@naver.com)

        if [ -s $0.pid ]
        then exist_pid=`cat $0.pid`
        if [ -z `ps -e|grep "^$exist_pid "` ]
        then
                rm -f $0.pid;exec_confirm="Y"
        else exec_confirm="N"
                        echo -e "\e[1;32mShell has already running...\e[0m"
fi
        else exec_confirm="Y"
fi


# Edit : JDY
# Global Variables
variables ()
{
date1=`date +%Y%m%d -d '5day ago'`
date2=`date +"%Y%m%d"`
dir2="$dir1/$date2/backup.log"
var1=`df -h | grep -v "boot\|tmpfs" | awk '{print $5}' | cut -d "%" -f 1 | sort -rh | head -1`
var2=`mkdir -p $dir1/$date2`
}

##########################################################################
#########################!!! Please Check !!!#############################
##########################################################################
# Backup Dir	### 아래 설정값을 확인해서 환경에 맞게 수정바람.
dir1="/devp/backup"	### 백업디렉토리 지정
limit1="70"	### 디스크 최대용량 설정
bdir1="/etc"	### 백업1타겟
bdir2="/var/spool/cron"	### 백업2 타겟
bdir3="/devp/app"	### 백업3 타겟
#bdir4="/devp/stor"	### 백업4 타겟
##########################################################################
##########################################################################
##########################################################################

# Added Schedule (cron)
variables
whi1=`which crontab`
whi2=`which sh`
var3=`$whi1 -l | grep .sync.sh | wc -l`
if [ "$var3" = "0" ] ; then
	echo "### BACKUP" >> /var/spool/cron/root
	echo "0 3 * * * /bin/sh $dir1/.sync.sh" >> /var/spool/cron/root
fi

# Backup File Move
whi3=`which find`
whi4=`which mv`
var4=`$whi3 $dir1/ -name ".sync.sh" | wc -l`
if [ "$var4" = "0" ] ; then
	var5=`$whi3 /* -name ".sync.sh"|grep -v "proc"`
	$whi4 $var5 $dir1/
fi

# Backup
if [ "$exec_confirm" == "Y" ] ; then
	$var2
	echo $$ > $0.pid
	
	variables
	if [ "$var1" -lt "$limit1" ] ; then
		echo -e " \n Starting Backup." >> $dir2
		echo " TIME : `date +%Y%m%d_%T` " >> $dir2
		echo " DISK USED : $var1 % " >> $dir2
		echo " BACKUP DIR : $bdir1" >> $dir2
		rsync -av --progress $bdir1 $dir1/$date2/
		err1=`echo $?`
		echo -e "ERROR : $err1" >> $dir2
		echo "##############################" >> $dir2
	else
		echo -e "$bdir1, FAILD BACKUP." >> $dir2
		echo "##############################" >> $dir2
	fi
	
	variables
	if [ "$var1" -lt "$limit1" ] ; then
		echo -e " \n Starting Backup." >> $dir2
		echo " TIME : `date +%Y%m%d_%T` " >> $dir2
		echo " DISK USED : $var1 % " >> $dir2
		echo " BACKUP DIR : $bdir2" >> $dir2
		rsync -av --progress $bdir2 $dir1/$date2/
		err1=`echo $?`
		echo -e "ERROR : $err1" >> $dir2
		echo "##############################" >> $dir2
	else
		echo -e "$bdir2, FAILD BACKUP." >> $dir2
		echo "##############################" >> $dir2
	fi
	
	variables
	if [ "$var1" -lt "$limit1" ] ; then
		echo -e " \n Starting Backup." >> $dir2
		echo " TIME : `date +%Y%m%d_%T` " >> $dir2
		echo " DISK USED : $var1 % " >> $dir2
		echo " BACKUP DIR : $bdir3" >> $dir2
		rsync -av --progress --exclude=mariadb $bdir3 $dir1/$date2/
		err1=`echo $?`
		echo -e "ERROR : $err1" >> $dir2
		echo "##############################" >> $dir2
	else
		echo -e "$bdir3, FAILD BACKUP." >> $dir2
		echo "##############################" >> $dir2
	fi
	
#	variables
#	if [ "$var1" -lt "$limit1" ] ; then
#		echo -e " \n Starting Backup." >> $dir2
#		echo " TIME : `date +%Y%m%d_%T` " >> $dir2
#		echo " DISK USED : $var1 % " >> $dir2
#		echo " BACKUP DIR : $bdir4" >> $dir2
#		rsync -av --progress --exclude=gwdata $bdir4 $dir1/$date2/
#		err1=`echo $?`
#		echo -e "ERROR : $err1" >> $dir2
#		echo "##############################" >> $dir2
#	else
#		echo -e "$bdir4, FAILD BACKUP." >> $dir2
#		echo "##############################" >> $dir2
#	fi
rm -f $0.pid
fi

# Delete
$whi3 $dir1/ -name "$date1*" -exec rm -rf {} \;
