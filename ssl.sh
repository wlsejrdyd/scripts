#!/bin/bash
# made by jdy

clear
echo  "====================================================="
echo -e "\n\033[33m��apache v2 create SSL key,csr��\033[0m \n"
echo  "====================================================="


echo -e  "\n\033[32m Backup the conf files(httpd/ssl) \033[0m \n"
date=`date +%Y%m%d`
conf=/usr/local/apache/conf/httpd.conf
ssl=`cat /usr/local/apache/conf/httpd.conf | grep ssl.conf | grep -v "#" | awk '{print $2}'`
ssl1=/usr/local/apache/$ssl
cp -ar $conf $conf.$date
cp -ar $ssl1 $ssl1.$date
ls -lR /usr/local/apache/conf/ | grep $date

echo -e "\n\033[32m Check Loaded SSL MODULE \033[0m"
cat /usr/local/apache/conf/httpd.conf | grep mod_ssl.so
echo -e ""


while [ : ]
do
	echo -n "CREATE KEY FILE? (y/n) : "
	read VAR
		if [ "$VAR" = "y" ]
		then
		echo -e " WRITE HERE DOMAIN, \n ex)www.deok.kr "
		read DNS1
		echo -e " WRITE PASSWORD FOR KEY FILE. "
		openssl genrsa -des3 -out ${DNS1}.key 2048
		break
	elif [ "$VAR" = "n" ]
			then
			echo -e "\n\033[31m you cancle KEY, BYE! \033[0m\n"
			break
	else
				continue
	fi
done


while [ : ]
do
	echo -n "CREATE CSR FILE? (y/n) : "
	read VAR
		if [ "$VAR" = "y" ]
		then
		echo -e "KEY => CSR "
		echo -e " CREATE CSR FILE. "
		openssl req -new -key ${DNS1}.key -out ${DNS1}.csr
		echo -e " cat the csr file. "
		cat ${DNS1}.csr
		break
	elif [ "$VAR" = "n" ]
			then
			echo -e "\n\033[31m you cancle CSR, BYE! \033[0m\n "
			break
	else
				continue
	fi
done

while [ : ]
do
	echo -n "IF YOU WANT WITHOUT PASSWORD? (y/n) : "
	read VAR
		if [ "$VAR" = "y" ]
		then
		echo -e "\n\033[33m copy key file and without password \033[0m \n"
		cp -ar ${DNS1}.key ${DNS1}.without
		echo -e "\n\033[31m WIRTE PASSWORD \033[0m \n"
		openssl rsa -in ${DNS1}.without -out ${DNS1}.key
		break
	elif [ "$VAR" = "n" ]
			then
			echo -e "\n\033[31m you cancle, BYE! \033[0m \n "
			break
	else
				continue
	fi
done
