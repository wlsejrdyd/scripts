#!/bin/bash

### Variables
ranpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!#%^*()_+'|fold -w 11 |sed 1q)

### Banner
bann ()
{ echo -e "## Make by. JDY ##"
}
bann

read -p "What do you work? 1. user created(1) | 2. add port(2) : " num1
case $num1 in 1 | user )
read -p "[INFO] Enter create username : " user1
if [ $(cat /etc/passwd | grep ${user1}|wc -l) -eq 0 ] ; then
	read -p "[INFO] Enter usercomments : " comm1
	comm2=$(/usr/bin/cat /etc/passwd | grep ${user1} | wc -l)
		if [ -z "${comm1}" ] ; then
			echo "[FAILED] YOU MUST ENTER COMMENTS. TRY AGAIN."
			exit 1
		fi
	echo -e "[INFO] Use password? (Copy & Paste) : $ranpw"
	/usr/sbin/useradd ${user1} -c "${comm1}" && passwd ${user1}
	echo -e "[INFO] passwd files..\n$(/usr/bin/cat /etc/passwd | grep ${user1})"
	echo -e "[INFO] ${user1}\n$(/usr/bin/chage -l ${user1}|head -2)"
	echo -e "${user1} ALL=(ALL) ALL" > /etc/sudoers.d/${user1}
	ssh1=$(/usr/bin/cat /etc/ssh/sshd_config | grep -i "permitrootlogin no"|grep -v "^#" | wc -l)
	ssh2=$(/usr/bin/cat /etc/ssh/sshd_config |grep -i "permitrootlogin yes"|grep -v "^#" | wc -l)
		if [ ${ssh1} -eq 0 ] || [ ${ssh2} -eq 1 ]  ; then
			/usr/bin/sed -i "/^PermitRoot/d" /etc/ssh/sshd_config
			echo "PermitRootLogin no" >> /etc/ssh/sshd_config
			systemctl restart sshd
		else
			echo ""
		fi
fi
;;
2 | firewall )
echo -e "[INFO] If you want to add are ports... CANT!"
read -p "[INFO] Enter port : " port
/usr/bin/systemctl restart firewalld
/usr/bin/firewall-cmd --permanent --add-port=${port}/tcp
/usr/bin/firewall-cmd --reload
/usr/bin/firewall-cmd --list-ports
;;
esac
