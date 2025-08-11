#!/bin/bash
# made by jindeokyong 

##########################################################################
#########################!!! Please Check !!!#############################
##########################################################################
# 아래 설정값을 확인해서 환경에 맞게 수정바람.
dir1="/backup" # 백업디렉토리 지정
backup_target_dir="/etc /usr /var" # 백업타겟
backup_file_name="localbackup_v0.1.sh" # 백업 스크립트 파일 이름
##########################################################################

# Global Variables
date1=`date +%Y%m%d -d '5day ago'`
date2=`date +"%Y%m%d"`
dir2="$dir1/$date2/backup.log"
disk_usage_check ()
{
var1=`df -h | grep -v "boot\|tmpfs\|sr0" | awk '{print $5}' | cut -d "%" -f 1 | sort -rh | head -1`
        if [ ! -d ${dir2} ] ; then
                mkdir -p ${dir1}/${date2}
        fi
}

# Added Schedule (cron)
whi1=`which crontab`
whi2=`which sh`
var3=`$whi1 -l | grep ${backup_file_name} | wc -l`
        if [ "$var3" = "0" ] ; then
                echo "### BACKUP" >> /var/spool/cron/root
                echo "0 3 * * * /bin/sh $dir1/${backup_file_name}" >> /var/spool/cron/root
        fi

# Move Backup Scriptfile
whi3=`which find`
whi4=`which mv`
var4=`$whi3 $dir1/ -name "${backup_file_name}" | wc -l`
        if [ "$var4" = "0" ] ; then
                if [ ! -d ${dir1} ] ; then
                        mkdir ${dir1}
                fi
                var5=`$whi3 /* -name "${backup_file_name}"|grep -v "proc"`
                $whi4 $var5 $dir1/
        fi

# Backup
for backup in ${backup_target_dir}
do
        disk_usage_check
        if [ "$var1" -lt "70" ] ; then
                echo -e " \n Starting Backup." >> $dir2
                echo " TIME : `date +%Y%m%d_%T` " >> $dir2
                echo " DISK USED : $var1 % " >> $dir2
                echo " BACKUP DIR : ${backup}" >> $dir2
                rsync -avz ${backup} $dir1/$date2/
                err1=`echo $?`
                echo -e "ERROR : $err1" >> $dir2
                echo "##############################" >> $dir2
        else
                echo -e "${backup}, FAILD BACKUP." >> $dir2
                echo "##############################" >> $dir2
        fi
done

# Delete
$whi3 $dir1/ -name "$date1*" -exec rm -rf {} \;
