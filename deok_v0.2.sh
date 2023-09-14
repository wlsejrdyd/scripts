### Last Run DATE : 2022-05-09 (13:16:16)
### Last Run DATE : 2021-11-29 (17:03:52)
pwdpath=`pwd -P`
sed -i "1 i\\### Last Run DATE : `date +'%Y-%m-%d (%H:%M:%S)'`" $pwdpath/deok.sh
#!/bin/bash
banners ()
{ echo -e " \n\033[0;34m###########################\nMake By. JDY \n한번입력한 값은 바꿀수 없습니다. 주의해서 입력해주세요.\nLinux 8 버전 Private환경은 지원하지 않습니다.\n###########################\033[0m " 
}
banners

read -p "You ready for installration? : " anw1
case "$anw1" in y | Y | yes | YES ) ;;
* )
exit 1 ;;
esac

### Global Variable
###
jdy1=`cat /opt/config | wc -l` > /dev/null
if [ "$jdy1" -le  "5" ] ; then
	echo -e " \n\033[0;35m[INFO] Global Variables Save data for /opt/config !!!\033[0m"
	echo -e " \n\033[0;32mEnter \033[0;33mSource File PATH.\n \033[0;35m Ex) /root/source\033[0m "
	read path1
	dir1=$path1
	echo -e "DIR1 : $path1" > /opt/config
	mkdir -p $path1
	echo -e " \n\033[0;32mEnter \033[0;33mWork Directory PATH.\n \033[0;35mEx) prd or devp\033[0m "
	read dir2
	echo -e "DIR2 : $dir2" >> /opt/config
	mkdir -p /$dir2/app /$dir2/log /$dir2/stor
	echo -e " \n\033[0;32mEnter \033[0;33mUSER NAME.\n \033[0;35mEx) appservice\033[0m "
	read user1
	echo -e "USER : $user1" >> /opt/config
	echo -e " \n\033[0;32mEnter \033[0;33mGROUP NAME.\n \033[0;35mEx) appusers\033[0m "
	read group1
	echo -e "GROUP : $group1" >> /opt/config
	echo -e " \n\033[0;32mEnter \033[0;33mENVIRONMENT.\n \033[0;35mEx) public or private\033[0m "
	read env1
	echo -e "ENV : $env1" >> /opt/config
	if grep '\ 7\.' /etc/redhat-release &>/dev/null; then
	export os1='7'
	elif grep '\ 8\.' /etc/redhat-release &>/dev/null; then
	export os1='8'
	fi
	echo -e "OS : $os1" >> /opt/config
else
	cat /opt/config
	echo -n " You want use old data? (y/n) : "
	read key1
	if [ $key1 == "y" ] ; then
		cat1=`cat /opt/config | grep DIR1 | sort | uniq -c | awk '{print $4}'`
		path1=$cat1
		dir1=$path1
		cat2=`cat /opt/config | grep DIR2 | sort | uniq -c | awk '{print $4}'`
		dir2=$cat2
		cat3=`cat /opt/config | grep USER | sort | uniq -c | awk '{print $4}'`
		user1=$cat3
		cat4=`cat /opt/config | grep GROUP | sort | uniq -c | awk '{print $4}'`
		group1=$cat4
		cat5=`cat /opt/config | grep ENV | sort | uniq -c | awk '{print $4}'`
		env1=$cat5
		cat6=`cat /opt/config | grep OS | sort | uniq -c | awk '{print $4}'`
		os1=$cat6
		echo -e ""
	elif [ $key1 == "n" ] ; then
		echo -e " \n\033[0;35m[INFO] Global Variables Save data for /opt/config !!!\033[0m"
		echo -e " \n\033[0;32mEnter \033[0;33mSource File PATH.\n \033[0;35m Ex) /root/source\033[0m "
		read path1
		dir1=$path1
		echo -e "DIR1 : $path1" > /opt/config
		mkdir -p $path1
		echo -e " \n\033[0;32mEnter \033[0;33mWork Directory PATH.\n \033[0;35mEx) prd or devp\033[0m "
		read dir2
		echo -e "DIR2 : $dir2" >> /opt/config
		mkdir -p /$dir2/app /$dir2/log /$dir2/stor
		echo -e " \n\033[0;32mEnter \033[0;33mUSER NAME.\n \033[0;35mEx) appservice\033[0m "
		read user1
		echo -e "USER : $user1" >> /opt/config
		echo -e " \n\033[0;32mEnter \033[0;33mGROUP NAME.\n \033[0;35mEx) appusers\033[0m "
		read group1
		echo -e "GROUP : $group1" >> /opt/config
		echo -e " \n\033[0;32mEnter \033[0;33mENVIRONMENT.\n \033[0;35mEx) public or private\033[0m "
		read env1
		echo -e "ENV : $env1" >> /opt/config
		if grep '\ 7\.' /etc/redhat-release &>/dev/null; then
			export os1='7'
		elif grep '\ 8\.' /etc/redhat-release &>/dev/null; then
			export os1='8'
		fi
		echo -e "OS : $os1" >> /opt/config
	fi
fi

### Time Set, User,Group
###
while [ : ]
do
var4=`cat /opt/config | grep CREATE | wc -l`
if [ "$var4" == "0" ] ; then
echo -n " Time Synchronization, And Create a User (y/n) : "
read var1
        if [ "$var1" = "y" ] ; then
                echo -e " \n\033[0;32mStart Time Sync.\033[0m "
                timedatectl set-timezone Asia/Seoul
                echo -e " \033[0;32m`date`\033[0m "
                echo -e " \n\033[0;32mEnter \033[0;33mUser Infomation.\n\033[0;35mEx)\n 1. Uid\n 2. Gid\033[0m "
		var2=`cat /etc/passwd | grep $user1 | wc -l`
		var3=`cat /etc/group | grep $group1 | wc -l`
                if [ "$var2" == "0" ] && [ "$var3" == "0" ] ; then
                        read uid1
			read gid1
                        chmod o-r /etc/skel/.*
                        groupadd -g $gid1 $group1
                        useradd -g $group1 -u $uid1 $user1
                        echo "$user1      ALL=(ALL)       ALL" >> /etc/sudoers
                        cat /etc/passwd | grep $uid1
                        passwd $user1
                        echo -e " \n\033[0;32mDone.\n\033[0m "
			echo "CREATE : OK" >> /opt/config
                        continue
                else
                        echo -e " \n\033[0;31mID or GROUP Already.\n\033[0m "
                        break
                fi
        elif [ "$var1" = "n" ] ; then
                echo -e " \n\033[0;31mCancel, Go to Next Step...\033[0m\n "
                break
        else
                continue
        fi
else
	break
fi
done

### Packages Install
###
while [ : ]
do
var2=`cat /opt/config | grep -i packages | wc -l`
if [ "$var2" == "0" ] ; then
echo -n " Installing Packages (y/n) : "
read var1
	if [ "$var1" = "y" ] ; then
		if [ "$env1" = "public" ] ; then
			if [ "$os1" = "7" ] ; then
				echo -e " \n\033[0;32mNow Install Linux $os1 epel-release.\033[0m "
				yum install -y epel-release
				echo -e " \n\033[0;32mNow Install Linux $os1 Defaults Packages.\033[0m "
				yum install -y kernel kernel-devel openssl openssl-devel bash gcc gcc-c++ rdate vim wget net-tools rsyslog cronie ntp telnet lsof nfs-utils make rsync lvm2 sysstat unzip
			elif [ "$os1" = "8" ] ; then
				echo -e " \n\033[0;32mNow Install Linux $os1 epel-release.\033[0m "
				yum install -y epel-release
				echo -e " \n\033[0;32mNow Install Defaults, Linux $os1 Packages.\033[0m "
				yum install -y kernel kernel-devel openssl openssl-devel gcc gcc-c++ vim wget net-tools rsyslog cronie telnet lsof make rsync lvm2 tar cmake sysstat unzip
			fi
				echo -e " \n\033[0;32mDone.\033[0m\n "
				echo "PACKAGES : DONE" >> /opt/config
				break
		elif [ "$env1" = "private" ] ; then
			if [ "$os1" = "7" ] ; then
				echo -e " \n\033[0;32mPlease Enter \033[0;33mRPMs PATH.\n \033[0;35mEx) /root/rpms\033[0m  "
				read path1
				echo -e "[localrepo]\nname=localrepo\nbaseurl=file://$path1\ngpgcheck=0 " > /etc/yum.repos.d/local.repo
				echo -e " \n\033[0;32mNow Local Install Linux $os1 epel-release.\033[0m "
				yum install -y --disablerepo=* --enablerepo=localrepo epel-release
				echo -e " \n\033[0;32mNow Local Install Linux $os1 Defaults Packages.\033[0m "
				yum install -y --disablerepo=* --enablerepo=localrepo kernel kernel-devel openssl openssl-devel bash gcc gcc-c++ rdate vim wget rsyslog cronie ntp telnet lsof nfs-utils make rsync net-tools lvm2 unzip
				echo -e " \n\033[0;32mDone.\033[0m\n "
				echo "PACKAGES : DONE" >> /opt/config
				break
			elif [ "$os1" = "8" ] ;then
				echo -e " \n\033[0;31mFaild Install Linux $os1, Not Support. Sorry :(\033[0m\n "
				break
			fi
		fi
	elif [ "$var1" = "n" ] ; then
		echo -e " \n\033[0;31mCancel, Go to Next Step...\033[0m\n "
		break
	
	else
		continue
	fi
else
	break
fi
done

### Mount (LVM)
###
while [ : ]
do
var2=`fdisk -l | grep sd[b-z] | wc -l`
if [ "$var2" != "0" ] ; then
	if [ "$dir2" = "prd" ] ; then
		var3=`df -h | grep "\/app\|log\|stor" | wc -l`
		if [ "$var3" != "3" ] ; then
			mkdir -p /prd/app /prd/log /prd/stor
			echo -e " \n\033[0;32mLoaded DEV LIST.\033[0m"
			fdisk -l | grep "\/dev\/sd[b-z]"
			echo -e " \n\033[0;31mATTENTION!! Don't Use sda(OS)\033[0m "
			echo -e " \n\033[0;32mMount LIST.\033[0;m"
			df -h | grep "\/dev\/mapper\/$vg1"
			echo -e " \n\033[0;32mEnter \033[0;33mDevice Name.\n\033[0;35m[INFO] When you dont want LVM Configuration, Enter any key.\033[0m "
			read -p "Ex) sdb : " dev1
			case "$dev1" in sd[b-z])
			pvcreate /dev/$dev1
			echo -e " \n\033[0;32mEnter \033[0;33mVolume Group Name \n \033[0;35mEx) disk1\033[0m "
			read vg1
			vgcreate $vg1 /dev/$dev1
			echo -e " \n\033[0;32mEnter \033[0;33mLogical Name \n \033[0;35mEx) app or log or stor\033[0m "
			read lv1
			echo -e " \n\033[0;32mEnter \033[0;33mLogical Disk Size \n \033[0;35mEx) 100% or 50%\033[0m "
			read size1
			lvcreate -l $size1\FREE -n $lv1 $vg1
			dev2=`ls -l /dev/mapper | grep "$lv1" | awk '{print $9}'`
			mkfs.ext4 /dev/mapper/$dev2
			echo -e " \n\033[0;32mFile System is a ext4.\033[0m "
			mount /dev/mapper/$dev2 /$dir2/$lv1
			echo "/dev/mapper/$dev2	/$dir2/$lv1		ext4	defaults	1 1" >> /etc/fstab
			echo -e " \n\033[0;32mDone\033[0m\n "
			echo -e " \n\033[0;32mMount LIST.\033[0;m"
			df -h | grep "\/dev\/mapper\/$vg1"
			chown -R $user1:$group1 /$dir2/*
			esac
			read -p "When you want STOP LVM Configuration, Enter [n]." con1
			if [ "$con1" == "n" ] ; then
				break
			elif [ "$con1" != "n" ] ; then
				continue
			fi
		else
			break
		fi
	elif [ "$dir2" = "devp" ] ; then
		var3=`df -h | grep devp | wc -l`
		if [ "$var3" != "1" ] ; then
			mkdir -p /devp/app /devp/log /devp/stor
			echo -e " \n033[0;32mLoaded DEV LIST.\033[0m"
			fdisk -l | grep "\/dev\/sd[b-z]"
			echo -e " \n\033[0;31mATTENTION!! Don't Use sda(OS)\033[0m "
			echo -e " \n\033[0;32mEnter \033[0;33mDevice Name\033[0m "
			read -p "Ex) sdb : " dev1
			case "$dev1" in sd[b-z])
			pvcreate /dev/$dev1
			echo -e " \n\033[0;32mEnter \033[0;33mVolume Group Name \n \033[0;35mEx) disk1\033[0m "
			read vg1
			vgcreate $vg1 /dev/$dev1
			echo -e " \n\033[0;32mEnter \033[0;33mLogical Name \n \033[0;35mEx) devp\033[0m "
			read lv1
			echo -e " \n\033[0;32mEnter \033[0;33mLogical Disk Size \n \033[0;35mEx) 100% or 50%\033[0m "
			read size1
			lvcreate -l $size1\FREE -n $lv1 $vg1
			dev2=`ls -l /dev/mapper | grep "$lv1" | awk '{print $9}'`
			mkfs.ext4 /dev/mapper/$dev2
			echo -e " \n\033[0;32mFile System is a ext4.\033[0m "
			mount /dev/mapper/$dev2 /devp
			echo "/dev/mapper/$dev2 /devp             ext4    defaults        1 1" >> /etc/fstab
			echo -e " \n\033[0;32mDone\033[0m\n "
			echo -e " \n\033[0;32mMount LIST.\033[0;m"
			df -h | grep "\/dev\/mapper\/$vg1"
			mkdir -p /devp/app /devp/log /devp/stor
			chown -R $user1:$group1 /devp/*
			esac
			break
		else
			break
		fi
	else
		break
	fi
else
	break
fi
done

### Command history
###
while [ : ]
do
var2=`cat /etc/profile.d/* | grep "#CMD" | wc -l`
if [ "$var2" == "0" ] ; then
echo -n " Want History Command Log? (y/n) : "
read var1
	if [ "$var1" = "y" ] ; then
		echo "local1.notice	/var/log/.cmd.log" >> /etc/rsyslog.conf
		sed -i 's/cron.none/cron.none;local1.none/g' /etc/rsyslog.conf
		echo "#CMD LOG
HISTTIMEFORMAT=\"%Y-%m-%d [%H:%M:%S] \"
export HISTTIMEFORMAT
export MALLOC_CHECK_=0
function history_to_syslog() {
        declare USERCMD
        USERCMD=\$(fc -ln -0 2>/dev/null|sed 's/\t //')
        declare PP
        if [ \"\$USER\" == \"root\" ]
        then
                PP=\"]#\"
        else
                PP=\"]$\"
        fi
        if [ \"\$USERCMD\" != \"\$OLD_USERCMD\" ]
        then
 logger -p local1.notice -t bash -i \"\$USER\$(who am i|awk '{print \$5}'):\$PWD\$PP \$USERCMD\"
        fi
        OLD_USERCMD=\$USERCMD
        unset USERCMD PP
}
trap 'history_to_syslog' DEBUG " > /etc/profile.d/cmd.sh
		echo -e " \n\033[0;32mDone.\033[0m\n "
		break
	elif [ "$var1" = "n" ] ; then
		echo -e " \n\033[0;31mCancel, Go to Next Step...\033[0m\n "
		break
	else
		continue
	fi
else
	break
fi
done

### SELINUX Disable
### 
while [ : ]
do
var2=`sestatus | grep "enabled" | wc -l`
var3=`cat /etc/sysconfig/selinux  | grep SELINUX=disabled | grep -v "#" | wc -l`
if [ "$var2" != "0" ] && [ "$var3" != "1" ] ; then
echo -n " SELINUX Disable (y/n) : "
read var1
	if [ "$var1" = "y" ] ; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
		echo -e " \n\033[0;32mDone.\033[0m "
		echo -e " \n\033[0;32mSELINUX Disable.. \033[0;31mplase system reboot.\033[0m\n "
		break
	elif [ "$var1" = "n" ] ; then
		echo -e " \n\033[0;31mCancel, Go to Next Step...\033[0m\n "
                break
	else
		continue
	fi
else
	break
fi
done

### System stop/disable
###
while [ : ]
do
var2=`cat /opt/config | grep -i system | wc -l`
if [ "$var2" == "0" ] ; then
echo -n " System Service Stop and Disable (y/n) : "
read var1
	if [ "$var1" = "y" ] ; then
		if [ "$os1" = "7" ] ; then
			for deok1 in chronyd postfix rpcbind NetworkManager; do
			systemctl stop $deok1
			systemctl disable $deok1
			done
			systemctl start	ntpd
			systemctl enable ntpd
			echo -e " \n\033[0;31mStop/Disable : $deok1\033[0m\n\033[0;32mStart : ntpd\033[0m\n "
			sed -i '/^server/d' /etc/ntp.conf
			sed -i '/^restrict ::1/d' /etc/ntp.conf
			echo -e "server time.kriss.re.kr iburst" >> /etc/ntp.conf
			echo -e "server time2.kriss.re.kr" >> /etc/ntp.conf
			echo "System Service STOP : OK" >> /opt/config
			break
		elif [ "$os1" = "8" ] ; then
			for deok2 in postfix rpcbind ntp; do
			systemctl stop $deok2
			systemctl disable $deok2
			done
			systemctl start chronyd
			systemctl enable chronyd
			echo -e " \n\033[0;31mStop/Disable : $deok2\033[0m\n\033[0;32mStart : chronyd\033[0m\n "
			echo "System Service STOP : OK" >> /opt/config
			break
		fi
	elif [ "$var1" = "n" ] ; then
		echo -e " \n\033[0;31mCancel, Go to Next Step...\033[0m\n "
		break
	else
		continue
	fi

else
	break
fi

done


### Openfiles , IPV6 disable
### 
while [ : ]
do
var2=`cat /root/.bashrc | grep "vim" | wc -l`
if [ "$var2" != "1" ] ; then
echo -n " Parameter Modify, IPv6 Disable (y/n) : "
read var1
	if [ "$var1" = "y" ] ; then
		echo "*       soft    nofile  12288" >> /etc/security/limits.conf
		echo "*       hard    nofile  12288" >> /etc/security/limits.conf
		echo "install ipv6 /bin/true" > /etc/modprobe.d/disable_ipv6.conf
		echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
		echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
		echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
		echo "alias vi='vim'" >> /root/.bashrc
		sysctl -p
		echo -e " \n\033[0;32mDone.\033[0m\n "
		break
	elif [ "$var1" = "n" ] ; then
		echo -e " \n\033[0;31mCancel, Go to Next Step...\033[0m\n "
                break
	else
		continue
	fi
else
	break
fi
done

### MiddleWare Install(PUBLIC)
### 
echo -e "\n\033[0;35m[INFO] Static is a can insert path.\033[0m"
echo -n "Select Install by Auto or Static (y/n) : "
read rule1
while [ : ]
do
echo -e " \033[0;32mChoose Software. \n\033[0;33m - apache(1) \n - tomcat(2) \n - redis(3) \n - mariadb(4) \n - sentinel(5) \n - iRedMail(6) \n - cancel(7)\033[0m  "
read var1
if [ "$var1" = "apache" ] || [ "$var1" = "1" ] ; then
	if [ "$env1" = "public" ] ; then
		if [ "$rule1" = "y" ] || [ "$rule1" = "auto" ] ; then
			echo -e " \n\033[0;32mInstall APACHE Version 2.4.35.\033[0m\n "
			sleep 1
			yum install -y expat expat-devel jemalloc jemalloc-devel bzip2 pcre pcre-devel
			cd $dir1
			rm -rf $dir1/httpd-2.4.35
			tar xvfj $dir1/httpd-2.4.35.tar.bz2
			cd $dir1/httpd-2.4.35
			sed -i 's/#define DEFAULT_SERVER_LIMIT 16/#define DEFAULT_SERVER_LIMIT 256/g' $dir1/httpd-2.4.35/server/mpm/worker/worker.c
			sed -i 's/#define DEFAULT_SERVER_LIMIT 256/#define DEFAULT_SERVER_LIMIT 2048/g' $dir1/httpd-2.4.35/server/mpm/prefork/prefork.c
			sed -i 's/#define DEFAULT_SERVER_LIMIT 64/#define DEFAULT_SERVER_LIMIT 256/g' $dir1/httpd-2.4.35/server/mpm/event/event.c
			./configure --prefix=/$dir2/app/apache --with-included-apr --enable-so --enable-ssl --with-mpm=event --enable-rewrite --enable-proxy
			make -j `grep processor /proc/cpuinfo | wc -l` && make install
			sed -i 's/^#ServerName www.example.com:80/ServerName localhost/g' /$dir2/app/apache/conf/httpd.conf
			sed -i "s@User daemon@User $user1@g" /$dir2/app/apache/conf/httpd.conf
			sed -i "s@Group daemon@Group $group1@g" /$dir2/app/apache/conf/httpd.conf
			echo "CheckSpelling On" >> /$dir2/app/apache/conf/httpd.conf
			sed -i 's/^#LoadModule speling_module modules\/mod_speling.so/LoadModule speling_module modules\/mod_speling.so/g' /$dir2/app/apache/conf/httpd.conf
			mkdir -p /$dir2/log/apache
			rm -rf /$dir2/app/apache/logs
			ln -s /$dir2/log/apache /$dir2/app/apache/logs
			chown -R $user1.$group1 {/$dir2/log/apache,/$dir2/app/apache}
			chown root.root /$dir2/app/apache/bin/httpd
			chmod 4755 /$dir2/app/apache/bin/httpd
			echo "[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd.service(8)

[Service]
Type=forking
User=$user1
Group=$group1
ExecStart=/$dir2/app/apache/bin/apachectl start
ExecStop=/$dir2/app/apache/bin/apachectl stop

[Install]
WantedBy=multi-user.target " > /usr/lib/systemd/system/apache.service
			systemctl daemon-reload
			systemctl enable apache && systemctl start apache
			echo -e " \n\033[0;32mAPACHE Start File Here. \n (/usr/lib/systemd/system/apache.service)\033[0m"
			firewall-cmd --permanent --add-port={80,443}/tcp && firewall-cmd --reload
			firewall-cmd --reload
			netstat -npl | grep httpd
			continue
		elif [ "$rule1" = "n" ] || [ "$rule1" = "static" ]; then
			echo -e " \n\033[0;32mInstall APACHE Version 2.4.35.\033[0m\n "
			sleep 1
			yum install -y expat expat-devel jemalloc jemalloc-devel bzip2 pcre pcre-devel
			cd $dir1
			rm -rf $dir1/httpd-2.4.35
			tar xvfj $dir1/httpd-2.4.35.tar.bz2
			echo -e " \n\033[0;32mPlease Enter \033[0;33mAPACHE PATH. \n \033[0;35mEx) /$dir2/app/apache\033[0m "
			read path3
			rm -rf $path3
			cd $dir1/httpd-2.4.35
			sed -i 's/#define DEFAULT_SERVER_LIMIT 16/#define DEFAULT_SERVER_LIMIT 256/g' $dir1/httpd-2.4.35/server/mpm/worker/worker.c
			sed -i 's/#define DEFAULT_SERVER_LIMIT 256/#define DEFAULT_SERVER_LIMIT 2048/g' $dir1/httpd-2.4.35/server/mpm/prefork/prefork.c
			sed -i 's/#define DEFAULT_SERVER_LIMIT 64/#define DEFAULT_SERVER_LIMIT 256/g' $dir1/httpd-2.4.35/server/mpm/event/event.c
			./configure --prefix=$path3 --with-included-apr --enable-so --enable-ssl --with-mpm=event --enable-rewrite --enable-proxy
			make -j `grep processor /proc/cpuinfo | wc -l` && make install
			echo -e " \n\033[0;32mPlease Enter \033[0;33mAPACHE LOG PATH. \n \033[0;35mEx) /$dir2/log/apache\033[0m "
			read path4
			echo -e " \n\033[0;32mDone.\033[0m "
			sed -i 's/^#ServerName www.example.com:80/ServerName localhost/g' $path3/conf/httpd.conf
			sed -i "s@User daemon@User $user1@g" $path3/conf/httpd.conf
			sed -i "s@Group daemon@Group $group1@g" $path3/conf/httpd.conf
			echo "CheckSpelling On" >> $path3/conf/httpd.conf
			sed -i 's/^#LoadModule speling_module modules\/mod_speling.so/LoadModule speling_module modules\/mod_speling.so/g' $path3/conf/httpd.conf
			mkdir -p $path4
			rm -rf $path3/logs
			ln -s $path4 $path3/logs
			chown -R $user1.$group1 {$path3,$path4}
			chown root.root $path3/bin/httpd
			chmod 4755 $path3/bin/httpd
			echo "[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd.service(8)

[Service]
Type=forking
User=$user1
Group=$group1
ExecStart=$path3/bin/apachectl start
ExecStop=$path3/bin/apachectl stop

[Install]
WantedBy=multi-user.target " > /usr/lib/systemd/system/apache.service
			systemctl daemon-reload
			systemctl enable apache && systemctl start apache
			echo -e " \n\033[0;32mAPACHE Start File Here. \n (/usr/lib/systemd/system/apache.service)\033[0m"
			firewall-cmd --permanent --add-port={80,443}/tcp && firewall-cmd --reload
			netstat -npl | grep httpd
			continue
		else
			continue
		fi
	elif [ "$env1" = "private" ] ; then
		if [ "$os" == "7" ] ; then
			if [ "$rule1" = "y" ] || [ "$rule1" = "auto" ] ; then
				echo -e " \n\033[0;32mInstall APACHE Version 2.4.35.\033[0m\n "
				sleep 1
				yum install -y --disablerepo=* --enablerepo=localrepo expat expat-devel jemalloc jemalloc-devel bzip2 pcre pcre-devel
				cd $dir1
				rm -rf $dir1/httpd-2.4.35
				tar xvfj $dir1/httpd-2.4.35.tar.bz2
				cd $dir1/httpd-2.4.35
				sed -i 's/#define DEFAULT_SERVER_LIMIT 16/#define DEFAULT_SERVER_LIMIT 256/g' $dir1/httpd-2.4.35/server/mpm/worker/worker.c
				sed -i 's/#define DEFAULT_SERVER_LIMIT 256/#define DEFAULT_SERVER_LIMIT 2048/g' $dir1/httpd-2.4.35/server/mpm/prefork/prefork.c
				sed -i 's/#define DEFAULT_SERVER_LIMIT 64/#define DEFAULT_SERVER_LIMIT 256/g' $dir1/httpd-2.4.35/server/mpm/event/event.c
				./configure --prefix=/$dir2/app/apache --with-included-apr --enable-so --enable-ssl --with-mpm=event --enable-rewrite --enable-proxy
				make -j `grep processor /proc/cpuinfo | wc -l` && make install
				sed -i 's/^#ServerName www.example.com:80/ServerName localhost/g' /$dir2/app/apache/conf/httpd.conf
				sed -i "s@User daemon@User $user1@g" /$dir2/app/apache/conf/httpd.conf
				sed -i "s@Group daemon@Group $group1@g" /$dir2/app/apache/conf/httpd.conf
				echo "CheckSpelling On" >> /$dir2/app/apache/conf/httpd.conf
				sed -i 's/^#LoadModule speling_module modules\/mod_speling.so/LoadModule speling_module modules\/mod_speling.so/g' /$dir2/app/apache/conf/httpd.conf
				mkdir -p /$dir2/log/apache
				rm -rf /$dir2/app/apache/logs
				ln -s /$dir2/log/apache /$dir2/app/apache/logs
				chown -R $user1.$group1 {/$dir2/log/apache,/$dir2/app/apache}
				chown root.root /$dir2/app/apache/bin/httpd
				chmod 4755 /$dir2/app/apache/bin/httpd
				echo "[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd.service(8)

[Service]
Type=forking
User=$user1
Group=$group1
ExecStart=/$dir2/app/apache/bin/apachectl start
ExecStop=/$dir2/app/apache/bin/apachectl stop

[Install]
WantedBy=multi-user.target " > /usr/lib/systemd/system/apache.service
				systemctl daemon-reload
				systemctl enable apache && systemctl start apache
				echo -e " \n\033[0;32mAPACHE Start File Here. \n (/usr/lib/systemd/system/apache.service)\033[0m"
				firewall-cmd --permanent --add-port={80,443}/tcp && firewall-cmd --reload
				firewall-cmd --list-ports | grep "80\|443"
				netstat -npl | grep httpd
				continue
			elif [ "$rule1" = "n" ] || [ "$rule1" = "static" ]; then
				echo -e " \n\033[0;32mInstall APACHE Version 2.4.35.\033[0m\n "
				sleep 1
				yum install -y --disablerepo=* --enablerepo=localrepo expat expat-devel jemalloc jemalloc-devel bzip2 pcre pcre-devel
				cd $dir1
				rm -rf $dir1/httpd-2.4.35
				tar xvfj $dir1/httpd-2.4.35.tar.bz2
				echo -e " \n\033[0;32mPlease Enter \033[0;33mAPACHE PATH. \n \033[0;35mEx) /$dir2/app/apache\033[0m "
				read path3
				rm -rf $path3
				cd $dir1/httpd-2.4.35
				sed -i 's/#define DEFAULT_SERVER_LIMIT 16/#define DEFAULT_SERVER_LIMIT 256/g' $dir1/httpd-2.4.35/server/mpm/worker/worker.c
				sed -i 's/#define DEFAULT_SERVER_LIMIT 256/#define DEFAULT_SERVER_LIMIT 2048/g' $dir1/httpd-2.4.35/server/mpm/prefork/prefork.c
				sed -i 's/#define DEFAULT_SERVER_LIMIT 64/#define DEFAULT_SERVER_LIMIT 256/g' $dir1/httpd-2.4.35/server/mpm/event/event.c
				./configure --prefix=$path3 --with-included-apr --enable-so --enable-ssl --with-mpm=event --enable-rewrite --enable-proxy
				make -j `grep processor /proc/cpuinfo | wc -l` && make install
				echo -e " \n\033[0;32mPlease Enter \033[0;33mAPACHE LOG PATH. \n \033[0;35mEx) /$dir2/log/apache\033[0m "
				read path4
				echo -e " \n\033[0;32mDone.\033[0m "
				sed -i 's/^#ServerName www.example.com:80/ServerName localhost/g' $path3/conf/httpd.conf
				sed -i "s@User daemon@User $user1@g" $path3/conf/httpd.conf
				sed -i "s@Group daemon@Group $group1@g" $path3/conf/httpd.conf
				echo "CheckSpelling On" >> $path3/conf/httpd.conf
				sed -i 's/^#LoadModule speling_module modules\/mod_speling.so/LoadModule speling_module modules\/mod_speling.so/g' $path3/conf/httpd.conf
				mkdir -p $path4
				rm -rf $path3/logs
				ln -s $path4 $path3/logs
				chown -R $user1.$group1 {$path3,$path4}
				chown root.root $path3/bin/httpd
				chmod 4755 $path3/bin/httpd
				echo "[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd.service(8)

[Service]
Type=forking
User=$user1
Group=$group1
ExecStart=$path3/bin/apachectl start
ExecStop=$path3/bin/apachectl stop

[Install]
WantedBy=multi-user.target " > /usr/lib/systemd/system/apache.service
				systemctl daemon-reload
				systemctl enable apache && systemctl start apache
				echo -e " \n\033[0;32mAPACHE Start File Here. \n (/usr/lib/systemd/system/apache.service)\033[0m"
				firewall-cmd --permanent --add-port={80,443}/tcp && firewall-cmd --reload
				firewall-cmd --list-ports | grep "80\|443"
				netstat -npl | grep httpd
				continue
			else
				continue
			fi
		elif [ "$os1" == "8" ] ; then
			echo -e " \n\033[0;31mFaild Install Linux $os1, Not Support. Sorry :(\033[0m\n "
			continue
		else
			continue
		fi
	else
		continue
	fi
elif [ "$var1" = "tomcat" ] || [ "$var1" = "2" ] ; then
	if [ "$rule1" = "y" ] || [ "$rule1" = "auto" ] ; then
		read -p " Select Tomcat Version (7,8,9,10) : " ver1
		case $ver1 in 
			7 ) tomcat_ver=7.0.100 ;;
			8 ) tomcat_ver=8.5.72 ;;
			9 ) tomcat_ver=9.0.54 ;;
			10 ) tomcat_ver=10.0.12 ;;
		esac
		if [ "$ver1" = "7" ] || [ "$ver1" = "8" ] || [ "$ver1" = "9" ] || [ "$ver1" = "10" ] ; then
			echo -e " \n\033[0;32mInstall TOMCAT Version $ver1.\033[0m\n "
			sleep 1
			cd $dir1
			rm -rf $dir1/apache-tomcat-$tomcat_ver $dir1/zulu8.46.0.19-ca-jdk8.0.252-linux_x64 $dir1/tomcat-connectors-1.2.48-src /$dir2/app/jdk
			tar xvfz $dir1/apache-tomcat-$tomcat_ver.tar.gz
			tar xvfz zulu8.46.0.19-ca-jdk8.0.252-linux_x64.tar.gz
			tar xvfz tomcat-connectors-1.2.48-src.tar.gz
			rm -rf /$dir2/app/tomcat-ui /$dir2/app/tomcat-engine
			cp -ar $dir1/apache-tomcat-$tomcat_ver /$dir2/app/tomcat-ui
			cp -ar $dir1/apache-tomcat-$tomcat_ver /$dir2/app/tomcat-engine
			cp -ar $dir1/zulu8.46.0.19-ca-jdk8.0.252-linux_x64 /$dir2/app/jdk
			rm -rf /$dir2/app/jdk
			cp -ar $dir1/zulu8.46.0.19-ca-jdk8.0.252-linux_x64 /$dir2/app/jdk
			echo -e "JAVA_HOME=/$dir2/app/jdk \n export JAVA_OPTS=\"\${JAVA_OPTS} -Dfile.encoding=UTF-8 -DDEPLOY_PATH= -Xms2048m -Xmx2048m -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m -Djava.awt.headless=true\"" > /$dir2/app/tomcat-ui/bin/setenv.sh
			echo -e "JAVA_HOME=/$dir2/app/jdk \n export JAVA_OPTS=\"\${JAVA_OPTS} -Dfile.encoding=UTF-8 -DDEPLOY_PATH= -Xms2048m -Xmx2048m -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m -Djava.awt.headless=true\"" > /$dir2/app/tomcat-engine/bin/setenv.sh
			sed -i'' -r -e "/8009 -->/i\<Connector protocol=\"AJP/1.3\"" /$dir2/app/tomcat-ui/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\address=\"0.0.0.0\"" /$dir2/app/tomcat-ui/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\port=\"8009\"" /$dir2/app/tomcat-ui/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\secretRequired=\"false\"" /$dir2/app/tomcat-ui//conf/server.xml
			sed -i'' -r -e "/8009 -->/i\redierctPort=\"8443\"\ />" /$dir2/app/tomcat-ui//conf/server.xml
			sed -i'' -r -e "/8009 -->/i\<Connector protocol=\"AJP/1.3\"" /$dir2/app/tomcat-engine/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\address=\"0.0.0.0\"" /$dir2/app/tomcat-engine/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\port=\"8010\"" /$dir2/app/tomcat-engine/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\secretRequired=\"false\"" /$dir2/app/tomcat-engine/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\redierctPort=\"8443\"\ />" /$dir2/app/tomcat-engine/conf/server.xml
			sed -i  's/8005/8006/g' /$dir2/app/tomcat-engine/conf/server.xml
			sed -i  's/8080/8081/g' /$dir2/app/tomcat-engine/conf/server.xml
			cd $dir1/tomcat-connectors-1.2.48-src/native 
			./configure --with-apxs=/$dir2/app/apache/bin/apxs
			make -j `grep processor /proc/cpuinfo | wc -l` && make install
			mkdir -p /$dir2/log/tomcat-ui /$dir2/log/tomcat-engine
			rm -rf /$dir2/app/tomcat-ui/logs /$dir2/app/tomcat-engine/logs
			ln -s /$dir2/log/tomcat-ui /$dir2/app/tomcat-ui/logs 
			ln -s /$dir2/log/tomcat-engine /$dir2/app/tomcat-engine/logs
			chown -R $user1.$group1 /$dir2/log/tomcat*
			echo "LoadModule jk_module modules/mod_jk.so
<IfModule jk_module>
JkWorkersFile conf/workers.properties
JkMountFile conf/uri.properties
JkLogFile logs/mod_jk.log
JkLogLevel info
</IfModule> " >> /$dir2/app/apache/conf/httpd.conf
			echo "worker.list=worker1,worker2
worker.worker1.port=8009
worker.worker1.host=localhost
worker.worker1.type=ajp13

worker.worker2.port=8019
worker.worker2.host=localhost
worker.worker2.type=ajp13 " > /$dir2/app/apache/conf/workers.properties
			echo "/*.do=worker1
/*.jsp=worker1
/*.json=worker1
/covicore/*=worker1
/SynapDocViewServer/*=worker2
" > /$dir2/app/apache/conf/uri.properties
			echo "[Unit]
Description=Tomcat $tomcat_ver UI
After=syslog.target network.target

[Service]
Type=forking
LimitNOFILE=12288
User=$user1
Group=$group1
ExecStart=/$dir2/app/tomcat-ui/bin/startup.sh
ExecStop=/$dir2/app/tomcat-ui/bin/shutdown.sh
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target " > /usr/lib/systemd/system/tomcat-ui.service
			echo "[Unit]
Description=Tomcat $tomcat_ver Engine
After=syslog.target network.target

[Service]
Type=forking
LimitNOFILE=12288
User=$user1
Group=$group1
ExecStart=/$dir2/app/tomcat-engine/bin/startup.sh
ExecStop=/$dir2/app/tomcat-engine/bin/shutdown.sh
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target " > /usr/lib/systemd/system/tomcat-engine.service
			echo -e " \n\033[0;32mTOMCAT Start File Here. \n (/usr/lib/systemd/system/tomcat-ui.service). \n (/usr/lib/systemd/system/tomcat-engine.service). \033[0m"
			systemctl daemon-reload
			chown -R $user1.$group1 /$dir2/app/{tomcat-ui,tomcat-engine,apache}
			chown -R root.root /$dir2/app/apache/bin/httpd
			chmod 4755 /$dir2/app/apache/bin/httpd
			systemctl enable tomcat-ui && systemctl enable tomcat-engine
			systemctl start tomcat-ui && systemctl start tomcat-engine
			echo -e "\033[0;31mPlease wait 5 sec...\033[0m"
			sleep 5
			netstat -npl | grep java
			echo -e " \n\033[0;32mDone.\033[0m\n "
		else
			echo -e " \n\033[0;32mPlease Check Version.\033[0m "
			continue
		fi
	elif [ "$rule1" = "n" ] || [ "$rule1" = "static" ] ; then
		read -p " Select Tomcat Version (7,8,9,10) : " ver1
		case $ver1 in
			7 ) tomcat_ver=7.0.100 ;;
			8 ) tomcat_ver=8.5.72 ;;
			9 ) tomcat_ver=9.0.54 ;;
			10 ) tomcat_ver=10.0.12 ;;
		esac
		if [ "$ver1" = "7" ] || [ "$ver1" = "8" ] || [ "$ver1" = "9" ] || [ "$ver1" = "10" ] ; then
			echo -e " \n\033[0;32mInstall TOMCAT Version $tomcat_ver.\033[0m\n "
			sleep 1
			cd $dir1
			rm -rf $dir1/apache-tomcat-$tomcat_ver $dir1/zulu8.46.0.19-ca-jdk8.0.252-linux_x64 $dir1/tomcat-connectors-1.2.48-src
			tar xvfz $dir1/apache-tomcat-$tomcat_ver.tar.gz
			tar xvfz zulu8.46.0.19-ca-jdk8.0.252-linux_x64.tar.gz
			tar xvfz tomcat-connectors-1.2.48-src.tar.gz
			echo -e " \n\033[0;32mPlease Enter \033[0;33mTOMCAT-UI PATH. \n \033[0;35mEx) /$dir2/app/tomcat-ui\033[0m "
			read path1
			rm -rf $path1
			cp -ar $dir1/apache-tomcat-$tomcat_ver $path1
			echo -e " \n\033[0;32mPlease Enter \033[0;33mTOMCAT-ENGINE PATH. \n \033[0;35mEx) /$dir2/app/tomcat-engine\033[0m "
			read path2
			rm -rf $path2
			cp -ar $dir1/apache-tomcat-$tomcat_ver $path2
			echo -e " \n\033[0;32mPlease Enter \033[0;33mJDK(JAVA) PATH. \n \033[0;35mEx) /$dir2/app/jdk\033[0m "
			read path3
			rm -rf $path3
			cp -ar $dir1/zulu8.46.0.19-ca-jdk8.0.252-linux_x64 $path3
			echo -e "JAVA_HOME=$path3 \nexport JAVA_OPTS=\"\${JAVA_OPTS} -Dfile.encoding=UTF-8 -DDEPLOY_path= -Xms2048m -Xmx2048m -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m -Djava.awt.headless=true -Djava.awt.headless=true\"" > $path1/bin/setenv.sh
			echo -e "JAVA_HOME=$path3 \n export JAVA_OPTS=\"\${JAVA_OPTS} -Dfile.encoding=UTF-8 -DDEPLOY_path= -Xms2048m -Xmx2048m -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m -Djava.awt.headless=true -Djava.awt.headless=true\"" > $path2/bin/setenv.sh
			sed -i'' -r -e "/8009 -->/i\<Connector protocol=\"AJP/1.3\"" $path1/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\address=\"0.0.0.0\"" $path1/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\port=\"8009\"" $path1/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\secretRequired=\"false\"" $path1/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\redierctPort=\"8443\"\ />" $path1/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\<Connector protocol=\"AJP/1.3\"" $path2/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\address=\"0.0.0.0\"" $path2/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\port=\"8010\"" $path2/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\secretRequired=\"false\"" $path2/conf/server.xml
			sed -i'' -r -e "/8009 -->/i\redierctPort=\"8443\"\ />" $path2/conf/server.xml
			sed -i  's/8005/8006/g' $path2/conf/server.xml
			sed -i  's/8080/8081/g' $path2/conf/server.xml
			apxs1=`find /$dir2/* -name "apxs"`
			echo -e " \n\033[0;32mPlease Enter \033[0;33mapxs path, \033[0;35mStart Install Mod_jk.so.\033[0m "
			echo -e "\033[0;32mEx) $apxs1\033[0m"
			read path4
			cd $dir1/tomcat-connectors-1.2.48-src/native 
			./configure --with-apxs=$path4
			make -j `grep processor /proc/cpuinfo | wc -l` && make install
			apapath1=`ls -ld /$dir2/app/* | grep "apache"`
			echo -e " \n\033[0;32mPlease Enter \033[0;33mAPACHE PATH, \033[0;35mStart Edit httpd.conf File.\033[0m "
			echo -e "\033[0;32m$dir2 List\n$apapath1\033[0m"
			read path5
			echo -e " \n\033[0;32mPlease Enter \033[0;33mTOMCAT-UI LOG PATH. \n \033[0;35mEx) /$dir2/log/tomcat-ui\033[0m "
			read path6
			mkdir -p $path6
			rm -rf $path1/logs
			ln -s $path6 $path1/logs
			chown -R $user1.$group1 $path6/
			echo -e " \n\033[0;32mPlease Enter \033[0;33mTOMCAT-ENGINE LOG PATH. \n \033[0;35mEx) /$dir2/log/tomcat-engine\033[0m "
			read path7
			mkdir -p $path7
			rm -rf $path2/logs
			ln -s $path7 $path2/logs
			chown -R $user1.$group1 $path7/
			echo "LoadModule jk_module modules/mod_jk.so
<IfModule jk_module>
JkWorkersFile conf/workers.properties
JkMountFile conf/uri.properties
JkLogFile logs/mod_jk.log
JkLogLevel info
</IfModule> " >> $path5/conf/httpd.conf
			echo "worker.list=worker1,worker2
worker.worker1.port=8009
worker.worker1.host=localhost
worker.worker1.type=ajp13

worker.worker2.port=8019
worker.worker2.host=localhost
worker.worker2.type=ajp13 " > $path5/conf/workers.properties
			echo "/*=worker1" > $path5/conf/uri.properties
			echo "[Unit]
Description=Tomcat $tomcat_ver UI
After=syslog.target network.target

[Service]
Type=forking
LimitNOFILE=12288
User=$user1
Group=$group1
ExecStart=$path1/bin/startup.sh
ExecStop=$path1/bin/shutdown.sh
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target " > /usr/lib/systemd/system/tomcat-ui.service
			echo "[Unit]
Description=Tomcat $tomcat_ver Engine
After=syslog.target network.target

[Service]
Type=forking
LimitNOFILE=12288
User=$user1
Group=$group1
ExecStart=$path2/bin/startup.sh
ExecStop=$path2/bin/shutdown.sh
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target " > /usr/lib/systemd/system/tomcat-engine.service
			echo -e " \n\033[0;32mTOMCAT Start File Here. \n (/usr/lib/systemd/system/tomcat-ui.service). \n (/usr/lib/systemd/system/tomcat-engine.service). \033[0m"
			systemctl daemon-reload
			chown -R $user1.$group1 {$path1,$path2,$path3}
			chown -R root.root $path5/bin/httpd
			chmod 4755 $path5/bin/httpd
			firewall-cmd --permanent --add-port={8080,8081}/tcp && firewall-cmd --reload
			systemctl enable tomcat-ui && systemctl enable tomcat-engine
			systemctl start tomcat-ui && systemctl start tomcat-engine
			echo -e "\033[0;31mPlease wait 5 sec...\033[0m"
			sleep 5
			netstat -npl | grep java
			echo -e " \n\033[0;32mDone.\033[0m\n "
			continue
			fi
		fi
elif [ "$var1" = "redis" ] || [ "$var1" = "3" ] ; then
	if [ "$rule1" = "y" ] || [ "$rule1" = "auto" ] ;then
		cd $dir1
		rm -rf $dir1/redis-5.0.8
		tar xvfz redis-5.0.8.tar.gz
		cd $dir1/redis-5.0.8
		make && make PREFIX=/$dir2/app/redis install
		mkdir -p /$dir2/app/redis/dir_6379
		mkdir -p /$dir2/log/redis
		chown -R $user1.$group1 /$dir2/log/redis
		echo "bind 0.0.0.0
protected-mode yes
port 6379
daemonize yes
pidfile /$dir2/app/redis/redis_6379.pid
logfile /$dir2/log/redis/redis_6379.log
dir /$dir2/app/redis/dir_6379
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
requirepass \"Wls\" " > /$dir2/app/redis/6379.conf
		echo -e " \n\033[0;32mEnter \033[0;33mAUTH PASSWORD. \033[0m "
		read -s PASS1
		sed -i "s@Wls@$PASS1@g" /$dir2/app/redis/6379.conf
		chown -R $user1.$group1 /$dir2/app/redis
		echo "[Unit]
Description=Redis 5.0.8
After=syslog.target network.target

[Service]
Type=forking
LimitNOFILE=12288
User=$user1
Group=$group1
PIDFile=/$dir2/app/redis/redis_6379.pid
ExecStart=/$dir2/app/redis/bin/redis-server /$dir2/app/redis/6379.conf
ExecStop=/$dir2/app/redis/bin/redis-cli -p 6379 shutdown

[Install]
WantedBy=multi-user.target " > /usr/lib/systemd/system/redis.service
	elif [ "$rule1" = "n" ] || [ "$rule1" = "static" ] ; then
		cd $dir1
		rm -rf $dir1/redis-5.0.8
		tar xvfz redis-5.0.8.tar.gz
		cd $dir1/redis-5.0.8
		echo -e " \n\033[0;32mPlease Enter \033[0;33mREDIS PATH. \n \033[0;35mEx) /$dir2/app/redis\033[0m "
		read -s path1
		rm -rf $path1
		mkdir -p $path1/dir_6379
		make && make PREFIX=$path1 install
		echo -e " \n\033[0;32mPlease Enter \033[0;33mREDIS LOG PATH, \033[0;35mStart Edit Config File. \n Ex) /$dir2/log/redis\033[0m "
		read path2
		mkdir -p $path2
		chown -R $user1.$group1 $path2
		echo "bind 0.0.0.0
protected-mode yes
port 6379
daemonize yes
pidfile $path1/redis_6379.pid
logfile $path2/redis_6379.log
dir $path1/dir_6379
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
requirepass \"Wls\" " > $path1/6379.conf
		echo -e " \n\033[0;32mEnter \033[0;33mAUTH PASSWORD. \033[0m "
		read -s PASS1
		sed -i "s@Wls@$PASS1@g" $path1/6379.conf
		chown -R $user1.$group1 $path1
		echo "[Unit]
Description=Redis 5.0.8
After=syslog.target network.target

[Service]
Type=forking
LimitNOFILE=12288
User=$user1
Group=$group1
PIDFile=$path1/redis_6379.pid
ExecStart=$path1/bin/redis-server $path1/6379.conf
ExecStop=$path1/bin/redis-cli -p 6379 shutdown

[Install]
WantedBy=multi-user.target " > /usr/lib/systemd/system/redis.service
	fi
	echo -e " \n\033[0;32mREDIS Start File Here. \n (/usr/lib/systemd/system/redis.service).\033[0m "
	systemctl daemon-reload
	systemctl enable redis
	systemctl start redis
	firewall-cmd --permanent --add-port=6379/tcp
	firewall-cmd --reload
	firewall-cmd --list-ports | grep "6379\|6381"
	netstat -npl | grep redis
	echo -e " \n\033[0;32mDone.\033[0m\n "
	continue
elif [ "$var1" = "mariadb" ] || [ "$var1" = "4" ] ; then
		if [ "$rule1" = "y" ] || [ "$rule1" = "auto" ] ; then
			if [ "$os1" = "7" ] ; then
				echo -e " \n\033[0;32mStart Install MariaDB 10.4.14.\033[0m "
				sleep 1
				echo "[mariadb]
name=MariaDB
baseurl=https://archive.mariadb.org/mariadb-10.4.14/yum/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1 " > /etc/yum.repos.d/mariadb.repo
				yum remove -y MariaDB-*
				rm -rf /var/lib/mysql
				yum install -y MariaDB-server MairaDB-client
				rm -rf /etc/my.cnf*
				mkdir -p /$dir2/log/mariadb
				chown mysql. /$dir2/log/mariadb
				echo "[mysqld]
#user=$user1
port=3306
slow_query_log_file=/$dir2/log/mariadb/slow.log
log_error=/$dir2/log/mariadb/error.log
long_query_time=2
bind-address=0.0.0.0
skip-name-resolve
binlog_format=ROW
lower_case_table_names = 1
innodb_buffer_pool_size=2048M
innodb_buffer_pool_instances=8
innodb_read_io_threads=4
innodb_write_io_threads=4
max_connections=1024
open_files_limit=12288
table_open_cache = 1024
transaction-isolation=READ-COMMITTED
connect_timeout=15
wait_timeout=6000
character-set-server=utf8
default-storage-engine=InnoDB

[client]
port=3306
default-character-set=utf8 " > /etc/my.cnf
				chown -R $user1.$group1 /etc/my.cnf
				systemctl daemon-reload
				systemctl start mariadb
				systemctl enable mariadb
				echo -e " \n\033[0;32mAdd Port to Firewall.\033[0m "
				firewall-cmd --permanent --add-port=3306/tcp
				firewall-cmd --reload
				firewall-cmd --list-ports | grep "3306"
				netstat -npl | grep mysql
				mysql1=`find /* -name "mysql" -type f | grep "bin" | grep -v "mariadb-\|mysql-\|proc"`
				echo -e " \n\033[0;32mEnter \033[0;33mUser ID.\033[0m "
				read id1
				echo -e " \n\033[0;32mEnter \033[0;33mPassword.\033[0m "
				read -s pass1
				$mysql1 -e "grant all privileges on *.* to $id1@'localhost' identified by '$pass1';"
				$mysql1 -e "grant all privileges on *.* to $id1@'localhost' with grant option;"
				$mysql1 -e "grant all privileges on *.* to $id1@'%' identified by '$pass1';"
				$mysql1 -e "grant all privileges on *.* to $id1@'%' with grant option;"
				echo -e " \n\033[0;32mDone.\033[0m\n "
			elif [ "$os1" = "8" ] ; then
				echo -e " \n\033[0;32mStart Install MariaDB 10.4.14.\033[0m "
				sleep 1
				cd /etc/yum.repos.d/
				yum remove -y MariaDB-*
				rm -rf /var/lib/mysql
				curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
				bash mariadb_repo_setup --mariadb-server-version=10.4.14
				dnf install boost-program-options -y
				dnf module reset mariadb -y
				yum install -y MariaDB-server MariaDB-client
				rm -rf /etc/my.cnf*
				mkdir -p /$dir2/log/mariadb
				chown mysql. /$dir2/log/mariadb
				echo "[mysqld]
#user=$user1
port=3306
slow_query_log_file=/$dir2/log/mariadb/slow.log
log_error=/$dir2/log/mariadb/error.log
long_query_time=2
bind-address=0.0.0.0
skip-name-resolve
binlog_format=ROW
lower_case_table_names = 1
innodb_buffer_pool_size=2048M
innodb_buffer_pool_instances=8
innodb_read_io_threads=4
innodb_write_io_threads=4
max_connections=2048
open_files_limit=12288
table_open_cache = 1024
transaction-isolation=READ-COMMITTED
connect_timeout=15
wait_timeout=6000
character-set-server=utf8
default-storage-engine=InnoDB

[client]
port=3306
default-character-set=utf8 " > /etc/my.cnf
				chown -R $user1.$group1 /etc/my.cnf
				systemctl daemon-reload
				systemctl start mariadb
				systemctl enable mariadb
				echo -e " \n\033[0;32mAdd Port to Firewall.\033[0m "
				firewall-cmd --permanent --add-port=3306/tcp
				firewall-cmd --reload
				firewall-cmd --list-ports | grep "3306"
				netstat -npl | grep mysql
				mysql1=`find /* -name "mysql" -type f | grep "bin" | grep -v "mariadb-\|mysql-\|proc"`
				echo -e " \n\033[0;32mEnter \033[0;33mUser ID.\033[0m "
				read id1
				echo -e " \n\033[0;32mEnter \033[0;33mPassword.\033[0m "
				read -s pass1
				$mysql1 -e "grant all privileges on *.* to $id1@'localhost' identified by '$pass1';"
				$mysql1 -e "grant all privileges on *.* to $id1@'localhost' with grant option;"
				$mysql1 -e "grant all privileges on *.* to $id1@'%' identified by '$pass1';"
				$mysql1 -e "grant all privileges on *.* to $id1@'%' with grant option;"
				echo -e " \n\033[0;32mDone.\033[0m\n "
				continue
			fi
		elif [ "$rule1" = "n" ] || [ "$rule1" = "static" ] ; then
			if [ "$os1" = "7" ] ; then
				echo -e " \n\033[0;32mStart Install MariaDB 10.4.14.\033[0m "
				sleep 1
				echo "[mariadb]
name=MariaDB
baseurl=https://archive.mariadb.org/mariadb-10.4.14/yum/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1 " > /etc/yum.repos.d/mariadb.repo
				yum remove -y MariaDB-*
				rm -rf /var/lib/mysql
				yum install -y MariaDB-server MairaDB-client
				rm -rf /etc/my.cnf*
				echo -e " \n\033[0;32mEnter \033[0;33mLogfile PATH.\n \033[0;35mEx) /$dir2/log/mariadb\033[0m "
				read path2
				mkdir -p $path2
				chown -R mysql. $path2
				echo "[mysqld]
#user=$user1
port=3306
slow_query_log_file=$path2/slow.log
log_error=$path2/error.log
long_query_time=2
bind-address=0.0.0.0
skip-name-resolve
binlog_format=ROW
lower_case_table_names = 1
innodb_buffer_pool_size=2048M
innodb_buffer_pool_instances=8
innodb_read_io_threads=4
innodb_write_io_threads=4
max_connections=2048
open_files_limit=12288
table_open_cache = 1024
transaction-isolation=READ-COMMITTED
connect_timeout=15
wait_timeout=6000
character-set-server=utf8
default-storage-engine=InnoDB

[client]
port=3306
default-character-set=utf8 " > /etc/my.cnf
				chown -R $user1.$group1 /etc/my.cnf
				systemctl daemon-reload
				systemctl start mariadb
				systemctl enable mariadb
				echo -e " \n\033[0;32mAdd Port to Firewall.\033[0m "
				firewall-cmd --permanent --add-port=3306/tcp
				firewall-cmd --reload
				firewall-cmd --list-ports | grep "3306"
				netstat -npl | grep mysql
				mysql1=`find /* -name "mysql" -type f | grep "bin" | grep -v "mariadb-\|mysql-\|proc"`
				echo -e " \n\033[0;32mEnter \033[0;33mUser ID.\033[0m "
				read id1
				echo -e " \n\033[0;32mEnter \033[0;33mPassword.\033[0m "
				read -s pass1
				$mysql1 -e "grant all privileges on *.* to $id1@'localhost' identified by '$pass1';"
				$mysql1 -e "grant all privileges on *.* to $id1@'localhost' with grant option;"
				$mysql1 -e "grant all privileges on *.* to $id1@'%' identified by '$pass1';"
				$mysql1 -e "grant all privileges on *.* to $id1@'%' with grant option;"
				echo -e " \n\033[0;32mDone.\033[0m\n "
			elif [ "$os1" = "8" ] ; then
				echo -e " \n\033[0;32mStart Install MariaDB 10.4.14.\033[0m "
				sleep 1
				cd /etc/yum.repos.d/
				yum remove -y MariaDB-*
				rm -rf /var/lib/mysql
				curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
				bash mariadb_repo_setup --mariadb-server-version=10.4.14
				dnf install boost-program-options -y
				dnf module reset mariadb -y
				yum install -y MariaDB-server MariaDB-client
				rm -rf /etc/my.cnf*
				echo -e " \n\033[0;32mEnter \033[0;33mLogfile PATH.\n \033[0;35mEx) /$dir2/log/mariadb\033[0m "
				read path2
				mkdir -p $path2
				chown -R mysql. $path2
				sed -i "s@User=mysql@User=$user1@g" /usr/lib/systemd/system/mariadb.service
				sed -i "s@Group=mysql@Group=$group1@g" /usr/lib/systemd/system/mariadb.service
				echo "[mysqld]
#user=$user1
port=3306
slow_query_log_file=$path2/slow.log
log_error=$path2/error.log
long_query_time=2
bind-address=0.0.0.0
skip-name-resolve
binlog_format=ROW
lower_case_table_names = 1
innodb_buffer_pool_size=2048M
innodb_buffer_pool_instances=8
innodb_read_io_threads=4
innodb_write_io_threads=4
max_connections=2048
open_files_limit=12288
table_open_cache = 1024
transaction-isolation=READ-COMMITTED
connect_timeout=15
wait_timeout=6000
character-set-server=utf8
default-storage-engine=InnoDB

[client]
port=3306
default-character-set=utf8 " > /etc/my.cnf
				chown -R $user1.$group1 /etc/my.cnf
				systemctl daemon-reload
				systemctl start mariadb
				systemctl enable mariadb
				echo -e " \n\033[0;32mAdd Port to Firewall.\033[0m "
				firewall-cmd --permanent --add-port=3306/tcp
				firewall-cmd --reload
				firewall-cmd --list-ports | grep "3306"
				netstat -npl | grep mysql
				mysql1=`find /* -name "mysql" -type f | grep "bin" | grep -v "mariadb-\|mysql-\|proc"`
				echo -e " \n\033[0;32mEnter \033[0;33mUser ID.\033[0m "
				read id1
				echo -e " \n\033[0;32mEnter \033[0;33mPassword.\033[0m "
				read -s pass1
				$mysql1 -e "grant all privileges on *.* to $id1@'localhost' identified by '$pass1';"
				$mysql1 -e "grant all privileges on *.* to $id1@'localhost' with grant option;"
				$mysql1 -e "grant all privileges on *.* to $id1@'%' identified by '$pass1';"
				$mysql1 -e "grant all privileges on *.* to $id1@'%' with grant option;"
				echo -e " \n\033[0;32mDone.\033[0m\n "
			else
				continue
			fi
		fi
elif [ "$var1" = "sentinel" ] || [ "$var1" = "5" ] ; then
	if [ "$rule1" = "y" ] || [ "$rule1" = "auto" ] ; then
		echo -e " \n\033[0;32mStart Install to Sentinel\033[0m\n "
		var2=`netstat -npl | grep 6379 | wc -l`
		if [ $var2 = 0 ] ; then
			echo -e " \n\033[0;31mNot Found Redis Process...\033[0m\n "
		elif [ $var2 != 0 ] ; then
			echo -e " \n\033[0;32mRedis Restart...\033[0m "
			systemctl stop redis
			#sed -i 's/requirepass/#requirepass/g' /$dir2/app/redis/6379.conf
			systemctl start redis
			mkdir -p /$dir2/app/redis/dir_6381
			echo -e " \n\033[0;32mEnter \033[0;33mMASTER IP.\033[0m "
			read master1
			mkdir -p /$dir2/log/redis
			chown -R $user1.$group1 /$dir2/log/redis
			echo "masterauth \"Wls\"" >> /$dir2/app/redis/6379.conf
			echo "port 6381
daemonize yes
pidfile "/$dir2/app/redis/sentinel_6381.pid"
logfile "/$dir2/log/redis/sentinel_6381.log"
bind 0.0.0.0
 
dir "/$dir2/app/redis/dir_6381"
sentinel monitor mymaster $master1 6379 2
sentinel auth-pass mymaster \"Wls\" 
sentinel down-after-milliseconds mymaster 3000
sentinel failover-timeout mymaster 120000
sentinel deny-scripts-reconfig yes " > /$dir2/app/redis/6381.conf
			echo -e " \n\033[0;32mEnter \033[0;33mPASSWORD.\033[0m "
			read -s pass1
			sed -i "s@Wls@$pass1@g" /$dir2/app/redis/6381.conf
			sed -i "s@Wls@$pass1@g" /$dir2/app/redis/6379.conf
			chown -R $user1.$group1 /$dir2/app/redis
			echo "[Unit]
Description=Redis 5.0.8 – Sentinel
After=syslog.target network.target
 
[Service]
Type=forking
LimitNOFILE=12288
User=$user1
Group=$group1
PIDFile=/$dir2/app/redis/sentinel_6381.pid
ExecStart=/$dir2/app/redis/bin/redis-sentinel /$dir2/app/redis/6381.conf
ExecStop=/$dir2/app/redis/bin/redis-cli -p 6381 shutdown
 
[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/sentinel.service
			echo -e " \033[0;32mSENTINEL Start File Here. \n (/usr/lib/systemd/system/sentinel.service).\n\033[0;35m[INFO]Deleteing RequirePASS.\033[0m "
			sentinelvar1="replicaof $master1 6379"
			/$dir2/app/redis/bin/redis-cli $sentinelvar1
			systemctl daemon-reload
			systemctl start sentinel
			systemctl enable sentinel
			firewall-cmd --permanent --add-port=6381/tcp
			firewall-cmd --reload
			firewall-cmd --list-ports | grep "6379\|6381"
			netstat -npl | grep "senti"
			/$dir2/app/redis/bin/redis-cli info replication
			echo -e " \n\033[0;32mDone.\033[0m\n "
			continue
		fi
	elif [ "$rule1" = "n" ] || [ "$rule1" = "static" ] ; then
		echo -e " \n\033[0;32mStart Install to Sentinel\033[0m\n "
		var2=`netstat -npl | grep 6379 | wc -l`
		if [ $var2 = 0 ] ; then
			echo -e " \n\033[0;31mNot Found Redis Process...\033[0m\n "
		elif [ $var2 != 0 ] ; then
			echo -e " \n\033[0;32mEnter \033[0;33mREDIS PATH.\n \033[0;35mEx) /$dir2/app/redis\033[0m "
			read path1
			echo -e " \n\033[0;32mRedis Restart...\033[0m "
			systemctl stop redis
			sed -i 's/requirepass/#requirepass/g' $path1/6379.conf
			systemctl start redis
			mkdir -p $path1/dir_6381
			echo -e " \n\033[0;32mEnter \033[0;33mMASTER IP.\033[0m "
			read master1
			echo -e " \n\033[0;32mEnter \033[0;33mSENTINEL LOG PATH, \033[0;35mStart Edit Config File. \n Ex) /$dir2/log/redis\033[0m "
			read path2
			echo -e " \n\033[0;32mEnter \033[0;33mREDIS CONF PATH, \033[0;35m Delete Old MasterIP Record. \n Ex) $path1/6379.conf\033[0m "
			read path3
			sed -i '/replicaof/d' $path3
			mkdir -p $path2
			chown -R $user1.$group1 $path2
			echo "port 6381
daemonize yes
pidfile "$path1/sentinel_6381.pid"
logfile "$path2/sentinel_6381.log"
bind 0.0.0.0
 
dir "$path1/dir_6381"
sentinel monitor mymaster $master1 6379 2
sentinel auth-pass mymaster \"Wls\" 
sentinel down-after-milliseconds mymaster 3000
sentinel failover-timeout mymaster 120000
sentinel deny-scripts-reconfig yes " > $path1/6381.conf
			echo -e " \n\033[0;32mEnter \033[0;33mPASSWORD.\033[0m "
			read -s pass1
			sed -i "s@Wls@$pass1@g" $path1/6381.conf
			chown -R $user1.$group1 $path1
			echo "[Unit]
Description=Redis 5.0.8 – Sentinel
After=syslog.target network.target
 
[Service]
Type=forking
LimitNOFILE=12288
User=$user1
Group=$group1
PIDFile=$path1/sentinel_6381.pid
ExecStart=$path1/bin/redis-sentinel $path1/6381.conf
ExecStop=$path1/bin/redis-cli -p 6381 shutdown
 
[Install]
WantedBy=multi-user.targe" > /usr/lib/systemd/system/sentinel.service
			echo -e " \033[0;32mSENTINEL Start File Here. \n (/usr/lib/systemd/system/sentinel.service).\n\033[0;35m[INFO]Delete RequirePASS.\033[0m "
			sentinelvar1="replicaof $master1 6379"
			$path1/bin/redis-cli $sentinelvar1
			systemctl daemon-reload
			systemctl start sentinel
			firewall-cmd --permanent --add-port=6381/tcp
			firewall-cmd --reload
			firewall-cmd --list-ports | grep "6379\|6381"
			netstat -npl | grep "senti"
			$path1/bin/redis-cli info replication
			echo -e " \n\033[0;32mDone.\033[0m\n "
			continue
		fi
	fi
elif [ "$var1" = "iRedMail" ] || [ "$var1" = "6" ] ; then
	if [ "$os1" = "7" ] ; then
		cd $dir1
		tar xvfz iRedMail-1.2.1.tgz
		read -p " Insert MAIL DNS : " maildns1
		hostname -b $maildns1
		sed -i "s@User=$user1@User=mysql@g" /usr/lib/systemd/system/mariadb.service
		sed -i "s@Group=$group1@Group=mysql@g" /usr/lib/systemd/system/mariadb.service
		chown -R mysql. /var/lib/mysql
		sed -i '/skip-name-resolve/d' /etc/my.cnf
		sed -i '/user=/d' /etc/my.cnf
		systemctl daemon-reload
		systemctl restart mariadb
		export AUTO_USE_EXISTING_CONFIG_FILE=y
		export AUTO_INSTALL_WITHOUT_CONFIRM=y
		export AUTO_CLEANUP_REMOVE_SENDMAIL=y
		export AUTO_CLEANUP_REPLACE_FIREWALL_RULES=n
		export AUTO_CLEANUP_RESTART_FIREWALL=n
		export AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y
		sh $dir1/iRedMail-1.2.1/iRedMail.sh
		read -p " Did you want download MailServer Settings files? : " down1
		case $down1 in y | Y | yes | YES )
			cd $dir1
			echo -e " \n\033[0;35m[INFO] Download Dir : $dir1\033[0m\n "
		esac
		continue
	elif [ "$os1" = "8" ] ; then
		var2=`cat /etc/redhat-release | grep -i rocky | wc -l`
		cd $dir1
		rm -rf $dir1/iRedMail*
		tar xvfz iRedMail-1.2.1.tgz
		read -p " Insert MAIL DNS : " maildns1
		if [ "$var2" == "1" ] ; then
			mv /etc/redhat-release /etc/redhat-release.`date +%Y%m%d%H%M`
			echo "CentOS Linux release 8.4.2105" > /etc/redhat-release
			sed -i 's/yum -d 2/yum -d 2 --disablerepo=AppStream,PowerTools/g' $dir1/iRedMail-1.2.1/conf/global
		fi
		hostname -b $maildns1
		dnf install  http://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
		dnf module reset php -y
		dnf module enable php:remi-7.2 -y
		yum install -y yum-utils
		yum install -y dnf-plugins-core
		yum-config-manager --set-enable powertools
		sed -i "s@User=$user1@User=mysql@g" /usr/lib/systemd/system/mariadb.service
        	sed -i "s@Group=$group1@Group=mysql@g" /usr/lib/systemd/system/mariadb.service
		chown -R mysql. /var/lib/mysql
		sed -i '/skip-name-resolve/d' /etc/my.cnf
		sed -i '/user=/d' /etc/my.cnf
		systemctl daemon-reload
		systemctl restart mariadb
		sed -i 's/yum -d 2/yum -d 2 --disablerepo=AppStream,PowerTools/g' $dir1/iRedMail-1.2.1/conf/global
		export AUTO_USE_EXISTING_CONFIG_FILE=y
		export AUTO_INSTALL_WITHOUT_CONFIRM=y
		export AUTO_CLEANUP_REMOVE_SENDMAIL=y
		export AUTO_CLEANUP_REPLACE_FIREWALL_RULES=n
		export AUTO_CLEANUP_RESTART_FIREWALL=n
		export AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y
		bash $dir1/iRedMail-1.2.1/iRedMail.sh
		sed -i "s/notify\ stats/notify\ old_stats/" /etc/dovecot/dovecot.conf
		sed -i "s/ssl_protocols/#ssl_min_protocol/" /etc/dovecot/dovecot.conf
		sed -i "s/stats_refresh/old_stats_refresh/" /etc/dovecot/dovecot.conf
		sed -i "s/stats_track_cmds/old_stats_track_cmds/" /etc/dovecot/dovecot.conf
		sed -i "s/service\ stats/service\ old\-stats/" /etc/dovecot/dovecot.conf
		sed -i "s/stats\-mail/old\-stats\-mail/" /etc/dovecot/dovecot.conf
		sed -i "s/stats\-writer/old\-stats\-writer/" /etc/dovecot/dovecot.conf
		sed -i "s/imap_stats/imap_old_stats/" /etc/dovecot/dovecot.conf
		echo -e "\nssl_dh = </etc/pki/tls/dh2048_param.pem\n\nservice stats {\nunix_listener stats-reader {\nuser = vmail\ngroup = vmail\nmode = 0660\n}\n\nunix_listener stats-writer {\nuser = vmail\ngroup = vmail\nmode = 0660\n}\n}" >> /etc/dovecot/dovecot.conf
		read -p " Did you want download MailServer Settings files? : " down1
		case $down1 in y | Y | yes | YES )
			cd $dir1
			echo -e " \n\033[0;35m[INFO] Download Dir : $dir1\033[0m\n "
		esac
		continue
	else
		continue
	fi
elif [ "$var1" = "cancel" ] || [ "$var1" = "7" ] ; then
	echo -e " \n\033[0;31mCancel, Go to Next Step...\033[0m\n "
	break
else
	continue
fi
done

### Log Rotate
###
while [ : ]
do
var2=`find /etc/logrotate.d/ -name "cp_gw_logrotate" | wc -l`
if [ "$var2" == "0" ] ; then
echo -n " App Service Rotate log. (y/n) : "
read var1
	if [ "$var1" = "y" ] ; then
		echo "/$dir2/log/apache/*log
/$dir2/log/redis/*log
/$dir2/log/tomcat-ui/catalina.out
/$dir2/log/tomcat-engine/catalina.out
/$dir2/log/mariadb/*log
/$dir2/log/synap/tomcat/catalina.out
/$dir2/log/synap/hsql/*log
/$dir2/log/covimail/*log
{
	copytruncate
        daily
        missingok
        rotate 180
        compress
        delaycompress
        notifempty
        dateext
} " > /etc/logrotate.d/cp_gw_logrotate
		echo -e " \n\033[0;32mDone.\033[0m\n "
		chown $user1:$group1 /$dir2/*
		break
	elif [ "$var1" = "n" ] ; then
		echo -e " \n\033[0;31mCancel, Go to Next Step...\033[0m\n "
                break
	else
		continue
	fi
else
	break
fi
done

### Local Backup
###
while [ : ]
do
var2=`crontab -l | grep .sync.sh | wc -l`
if [ "$var2" = "0" ] ; then
for bin in rsync ; do
    which "$bin" > /dev/null
    if [ "$?" = "0" ] ; then
        bin_path="$(which $bin)"
        export bin_$bin="$bin_path"
    else
        echo "Error: Needed command \"$bin\" not found in PATH!"
        exit 1
    fi
done
echo -e "\n\033[0;35m[INFO] Start immediately after editing!!!\033[0m"
echo -n " Do you want to add a local backup to that server? (y/n) : "
read var1
	if [ "$var1" = "y" ] ; then
		cd $dir1
		vi $dir1/.sync.sh
		sh $dir1/.sync.sh
	elif [ "$var1" = "n" ] ; then
		echo -e " \n\033[0;31mCancel.\033[0m "
		break
	else
		continue
	fi
else
	break
fi
done
