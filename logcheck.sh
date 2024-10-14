#!/bin/bash
# made by jdy

date1=$(date +"%Y-%m-%d")
dir1="/remote_log"
file1="system.log"
log1="/var/log/systemlog_chk.log"
var1=$(ls ${dir1})
var2=$(ls  ${dir1}/*/$(date +%Y)/$(date +%m)/$(date +%d)/${file1}  | cut -d "/" -f -3 | awk -F "/" '{print $3}' | xargs)
var3=$(ls /remote_log/* -fd | awk -F "/remote_log/" '{print $2}' | wc -l)
var4=$(find /remote_log/*/$(date +%Y)/$(date +%m)/$(date +%d) -type f -name system.log | wc -l)
var5=$(echo | awk '{print '"$var3"' - '"$var4"'}')

if ! grep -q "${date1}" ${log1} ; then
        echo "${date1}" >> ${log1}
        echo "[수집중 서버] : ${var3} 대" >> ${log1}
        echo "[수집중지 서버] : ${var4} 대" >> ${log1}
        echo "[중지 된 서버 항목] : ${var5} 대" >> ${log1}

        for i in ${var1}
        do
                if ! echo ${var2} | grep -w ${i} > /dev/null ; then
                        echo -e "${i}" >> ${log1}
                fi
        done
        echo -e "done\n" >> ${log1}
fi