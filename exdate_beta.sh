#!/bin/bash
# made by jdy

dns1="${dns1}"
var1=$(cat /root/20231026/${dns1}.zone | awk '{print $1}' | grep -v "^$\|;\|@\|IN\|TTL\|[0-9]\|${dns1}")

echo "<html>"
echo "<head><title>HTTPS And SSL</title></head>"
echo "<body>"

echo "<table border="3">"
echo "<th>DNS LIST</th>"
echo "<th>HTTPS</th>"
echo "<th>ICMP</th>"

for i in ${var1}
do
echo -e "<tr><td>${i}.${dns1}</td>"
curl -I --connect-timeout 1 https://${i}.${dns1} &> /dev/null
if [ "$?" == "0" ] || [ "$?" == "60" ] ; then 
	echo "<td>"
	echo | openssl s_client -servername ${i}.${dns1} -connect ${i}.${dns1}:443 2> /dev/null  | openssl x509 -noout -dates
	echo "</td>"
	ping -c 1 ${i}.${dns1} | grep icmp &> /dev/null
	if [ "$?" != "0" ]; then 
		echo "<td>FAILED..</td></tr>"
	else	
		echo -e "<td>$(ping -c 1 ${i}.${dns1} | grep icmp)</td></tr>"
	fi
else 
	echo "<td>FAILED.</td>"
	ping -c 1 ${i}.${dns1} | grep icmp &> /dev/null
	if [ "$?" != "0" ]; then 
		echo "<td>FAILED..</td></tr>"
	else	
		echo -e "<td>$(ping -c 1 ${i}.${dns1} | grep icmp)</td></tr>"
	fi
fi
done

echo "</table>"
echo "</body>"
echo "</html>"
