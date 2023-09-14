#!/bin/bash

### Variables
ranpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!#%^*()_+'|fold -w 10 |sed 1q)

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
generate_password() {
    local length="$1"
    local has_upper=false
    local has_lower=false
    local has_digit=false
    local has_special=false

    while true; do
        password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!#%^*' | fold -w "$length" | sed 1q)

        for ((i = 0; i < length; i++)); do
            char="${password:$i:1}"
            if [[ "$char" =~ [A-Z] ]]; then
                has_upper=true
            elif [[ "$char" =~ [a-z] ]]; then
                has_lower=true
            elif [[ "$char" =~ [0-9] ]]; then
                has_digit=true
            else
                has_special=true
            fi
        done

        if $has_upper && $has_lower && $has_digit && $has_special; then
            echo "$password"
            break
        fi
    done
}

	ranpw=$(generate_password 10)
	echo -e "[INFO] Use password? (Copy & Paste) : $ranpw"
	/usr/sbin/useradd ${user1} -c "${comm1}" && passwd ${user1}
	echo -e "[INFO] passwd files..\n$(/usr/bin/cat /etc/passwd | grep ${user1})"
	echo -e "[INFO] ${user1}\n$(/usr/bin/chage -l ${user1}|head -2)"
	echo -e "${user1} ALL=(ALL) ALL" > /etc/sudoers.d/${user1}
	if [ -f "/etc/ssh/sshd_config.d/01-permitrootlogin.conf" ] ; then
		ssh1=$(/usr/bin/cat /etc/ssh/sshd_config.d/01-permitrootlogin.conf | grep -i "permitrootlogin no"|grep -v "^#" | wc -l)
		ssh2=$(/usr/bin/cat /etc/ssh/sshd_config.d/01-permitrootlogin.conf |grep -i "permitrootlogin yes"|grep -v "^#" | wc -l)
			if [ ${ssh1} -eq 0 ] || [ ${ssh2} -eq 1 ]  ; then
				/usr/bin/sed -i "/^PermitRoot/d" /etc/ssh/sshd_config.d/01-permitrootlogin.conf
				echo "PermitRootLogin no" >> /etc/ssh/sshd_config.d/01-permitrootlogin.conf
				systemctl restart sshd
			else
				echo ""
			fi
	else
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
else
	echo "user ${user1} already exists"
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
