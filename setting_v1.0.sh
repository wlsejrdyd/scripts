
#!/bin/bash



### Variables

ranpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!#%^*()_+'|fold -w 10 |sed 1q)



### Banner

bann ()

{

echo -e "## Make by. JDY ##"

}

bann



info ()

{

echo -e "\n\n안녕하세요. 신청하신 VM 생성이 완료되었습니다.\n

IP : $(ip -br addr | grep -v lo | awk '{print $3}' | cut -d / -f 1)

HOSTNAME : $(hostname)

ID : ${user1}(해당계정은 sudo 권한을 가진 계정입니다.)

PW : ${ranpw}

ALLOW PORT : $(firewall-cmd --list-port)



참고사항 )

root 접근권한은 막혀있습니다. 발급받으신 계정으로 관리자 권한 획득바랍니다.

???? 보안정책으로, 서버방화벽을 이용하시는 것을 권장 드립니다.

정책을 추가하실 경우 firewall-cmd 명령으로 하시면 됩니다."

}



read -p "[SELECT] user created(1) : " num1

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

                        echo "$ranpw"

                        break

                fi

        done

}



        ranpw=$(generate_password 10)

        echo -e "[INFO] password : $ranpw"

        /usr/sbin/useradd ${user1} -c "${comm1}" && echo "${ranpw}" | passwd --stdin ${user1}

        if [ "$?" = "0" ]; then

                echo -e "[INFO] password : $ranpw"

                logger -p local4.notice "ID : ${user1} PW : ${ranpw}"

        else

                echo "[ERROR] user delete, try again"

                userdel -rf ${user1}

                rm -rf /etc/sudoers.d/${user1}

                exit 1

        fi

        echo -e "[INFO] passwd files..\n$(/usr/bin/cat /etc/passwd | grep ${user1})"

        echo -e "[INFO] ${user1}\n$(/usr/bin/chage -l ${user1}|head -2)"

        echo -e "${user1} ALL=(ALL) ALL" > /etc/sudoers.d/${user1}

        chown ${user1}:${user1} /etc/sudoers.d/${user1}

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

        while [ : ] ; do

                echo -n "[SELECT] want allow port? (y/n) : "

                read var1

                case ${var1} in y | Y )

                        read -p "[INFO] Enter port : " port

                        /usr/bin/systemctl restart firewalld

                        /usr/bin/firewall-cmd --permanent --add-port=${port}/tcp

                        /usr/bin/firewall-cmd --reload

                        /usr/bin/firewall-cmd --list-ports

                        echo -e "\n[INFO] success"

                        info > ~/$(hostname)_info.txt

                        continue

                ;;

                n | N )

                        echo -e "\n[INFO] success"

                        info > ~/$(hostname)_info.txt

                        exit 0

                ;;

                * )

                        continue

                ;;

                esac

        done

else

        echo "[ERROR] user ${user1} already exists"

fi

;;

* )

        echo "[ERROR] select number."

        exit 1

;;

esac