#!/bin/bash
# made by jdy

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

rdmpw=$(generate_password 10)

#rdmpw1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!#%^*()_+'|fold -w 10 |sed 1q)
var1=$(cat /etc/passwd | awk -F":" '$3 >= 500' | awk -F":" '$3 <= 10000' | grep -v "^#" | grep "\/bin\/bash"| wc -l)
var2=$(cat /etc/passwd | awk -F":" '$3 >= 500' | awk -F":" '$3 <= 10000' | grep -v "^#" | grep "\/bin\/bash" | awk -F":" '{print $1}')
if [ "${var1}" -ge "1" ] ; then
	read -p "[user list]
${var2}
: " user1
	case ${user1} in root )
		logger -p local4.notice "root : ${rdmpw}"
		echo "${rdmpw}" | passwd root --stdin
		echo "${user1} : ${rdmpw}"
		if [ "$?" -ne "0" ] ; then
			echo " Try Again "
		fi
		;;
	* )
		logger -p local4.notice "${user1} : ${rdmpw}"
		echo "${rdmpw}" | passwd ${user1} --stdin
		echo "${user1} : ${rdmpw}"
		if [ "$?" -ne "0" ] ; then
			echo " Try Again "
		fi
		;;
	esac
else
	exit
fi
