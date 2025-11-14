#!/usr/bin/env bash
#made by jindeokyong


banner () {
echo -e "############################################################
해당 파일은 넥서스 커뮤니티 자산 입니다.
해당 스크립트의 모든 권리는 넥서스 커뮤니티에 있습니다.
$(date)
############################################################\n"
}
banner

line() {
printf -- '--------\n' | tee -a "$result" >/dev/null;
}


## Variables
set -u
svrip=$(ip -br addr | grep UP | grep -oP "\d+\.\d+\.\d+\.\d+")
result="${HOME}/$(hostname)_$svrip.txt"
ok="결과 : 양호"
nok="결과 : 취약"
now="현황 : "
ncnt=0
ocnt=0


## notice
banner > $result

echo -e "[NOTICE] 아래 항목에 대한 설정만 점검 합니다.
1. root permit login 및 ssh port, banner 설정 확인
2. su 명령어 권한 확인
3. 암호 복잡성 적용 확인
4. pam.d 보안 설정 확인
5. 일반계정UID/GID 0 사용 여부 확인
6. firewalld 또는 iptables 사용 여부 확인
7. session timeout 설정 확인
8. 암호 MIN/MAX 기간 설정 확인
9. 소유주가 없는 파일이거나 아무나 수정 가능한 파일 검색
10. host allow/deny 파일 확인
11. 실행 서비스 목록 제공(불필요 서비스 중지)" >> $result
line


## 1. PermitRootLogin, SSH Port, Banner
num1 () {
local file="/etc/ssh/sshd_config"
local title="PermitRootLogin, SSH Port, Banner"

local var1=$(sshd -T | grep -i permitrootlogin | grep -v "^#" | awk '{print $2}')
local var2=$(cat $file| grep -i port |grep -v "^#"| awk '{print $2}' | grep "^22$")
local var3=$(cat $file | grep -i banner | grep -v "^#" | wc -l)

echo -e "\n[1] $title\n*file : $file"
if [ $var1 == "yes" ] ; then
  echo -e "\n*[1-1] $nok\n$now\n$(sshd -T | grep -i permitrootlogin)"
  echo "PermitRootLogin 설정 no 로 변경 필요"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[1-1] $ok\n$now\n$(sshd -T | grep -i permitrootlogin)"
  echo "PermitRootLogin 설정 양호"
  ocnt=$((ocnt+1))
fi

if [ ! -z $var2 ] ; then
  echo -e "\n*[1-2] $nok\n$now\n$(sshd -T | grep -i "^port")"
  echo "Port 번호 변경 또는 비활성화 필요"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[1-2] $ok\n$now\n$(sshd -T | grep -i "^port")"
  echo "Port 번호 양호"
  ocnt=$((ocnt+1))
fi

if [ $var3 -eq 0 ] ; then
  echo -e "\n*[1-3] $nok\n$now\n$(sshd -T | grep -i "^banner")"
  echo "/etc/issue,/etc/issue.net,/etc/motd Banner 설정 필요"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[1-3] $ok\n$now\n$(sshd -T | grep -i "^banner")"
  echo "배너 설정 양호"
  ocnt=$((ocnt+1))
fi

line
}
num1 >> $result


## 2. su 명령어 권한 확인
num2 () {
local file="$(which su)"
local title="su 명령어 권한 확인"

local var1=$(stat $file | grep 4750 | wc -l)
local var2=$(find $file -name "su" -uid 0 | wc -l)
local var3=$(find $file -name "su" -gid 10 | wc -l)

echo -e "\n[2] $title\n*file : $file"
if [ $var1 -eq 0 ] || [ $var2 -eq 0 ] || [ $var3 -eq 0 ] ; then
  echo -e "\n*[2-1] $nok\n$now\n$(ls -l $file)"
  echo "권한(4750),소유그룹(wheel) 설정 필요"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[2-1] $ok\n$now\n$(ls -l $file)"
  echo "권한 수정 필요 없음"
  ocnt=$((ocnt+1))
fi

line
}
num2 >> $result


## 3. 암호 복잡성 적용 확인
num3 () {
local file="/etc/security/pwquality.conf"
local title="암호 복잡성 적용 확인"

local var1=$(cat $file | grep "minlen\|dcredit\|ucredit\|lcredit\|ocredit" | grep -v "^#" | wc -l)
local var2=$(cat $file | grep "minlen\|dcredit\|ucredit\|lcredit\|ocredit")

echo -e "\n[3] $title\n*file : $file"
if [ $var1 -eq 0 ] ; then
  echo -e "\n*[3-1] $nok\n$now\n$var2"
  echo "최소길이 = 9 나머지 = -1 권장"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[3-1] $ok\n$now\n$var2"
  echo "암호 복잡성 적용"
  ocnt=$((ocnt+1))
fi

line
}
num3 >> $result


## 4. pam.d 보안 설정 확인
num4 () {
local file="/etc/pam.d"
local title="pam.d 보안 설정 확인"

local var1=$(cat $file/su | grep wheel | grep required | grep -v "^#" | wc -l)
local var2=$(cat $file/su | grep wheel | grep required)
local var3=$(cat $file/password-auth | grep authfail | grep -v "^#" | wc -l)

echo -e "\n[4] $title\n*file : $file"
if [ $var1 -eq 0 ] ; then
  echo -e "\n*[4-1] $nok\n$now\n$var2"
  echo -e "$file/su"
  echo "주석 해제 필요"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[4-1] $ok\n$now\n$var2"
  echo "주석 해제 완료"
  ocnt=$((ocnt+1))
fi

if [ $var3 == 0 ] ; then
  echo -e "\n*[4-2] $nok\n$now\n"
  echo -e "$file/password-auth"
  echo "faillock 설정 필요, 재시도 5회 잠김시간 600초 권장"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[4-2] $ok\n$now\n"
  echo "faillock 설정 확인, 재시도 5회 잠김시간 600초 권장"
  ocnt=$((ocnt+1))
fi

line
}
num4 >> $result


## 5. 일반계정UID/GID 0 사용 여부 확인
num5 () {
local title="일반계정UID/GID 0 사용 여부 확인"

local var1=$(awk -F: '$3==0 {print $1}' /etc/passwd)
local var2=$(awk -F: '$3==0 {print $1}' /etc/group)

echo -e "\n[5] $title\n*file : /etc/passwd\n/etc/group"
if (( $(wc -l <<< $var1) != 1 || $(wc -l <<< $var2) != 1 )) ; then
  echo -e "\n*[5-1] $nok\n$now\n$var1\n$var2"
  echo "관리자 UID/GID 사용 계정 발견, 조치 필요"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[5-1] $ok\n$now\n$var1\n$var2"
  echo "UID/GID 정상 확인"
  ocnt=$((ocnt+1))
fi

line
}
num5 >> $result


## 6. firewalld 또는 iptables 사용 여부 확인
num6 () {
local title="firewalld 또는 iptables 사용 여부 확인"

local var1=$(systemctl is-active firewalld)

echo -e "\n[6] $title"
if [ $var1 == "inactive" ] ; then
  echo -e "\n*[6-1] $nok\n$now\n$var1\n$(iptables -nvL)\n$(firewall-cmd --list-all 2> /dev/null)"
  echo "방화벽 활성화 권장, 담당자에게 문의 후 활성화 필요"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[6-1] $ok\n$now\n$var1\n$(iptables -nvL)\n$(firewall-cmd --list-all 2> /dev/null)"
  echo "방화벽이 정상적으로 동작 중입니다."
  ocnt=$((ocnt+1))
fi

line
}
num6 >> $result


## 7. session timeout 설정 확인
num7 () {
local file="/etc/profile"
local title="session timeout 설정 확인"

local var1=$(cat $file | grep -i tmout | awk -F"="  '{print $2}')

echo -e "\n[7] $title\n*file : $file"
if [ -z $var1 ] ; then
  echo -e "\n*[7-1] $nok\n$now\n$var1"
  echo "TMOUT=600  환경변수 설정 필요"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[7-1] $ok\n$now\n$var1"
  echo "TMOUT 설정 확인"
  ocnt=$((ocnt+1))
fi

line
}
num7 >> $result


## 8. 암호 MIN/MAX 기간 설정 확인
num8 () {
local file="/etc/login.defs"
local title="암호 MIN/MAX 기간 설정 확인"

local var1=$(cat $file|grep -v "^#"  | grep -i "max_days" | awk '{print $2}')
local var2=$(cat $file|grep -v "^#"  | grep -i "min_days" | awk '{print $2}')
local var3=$(cat $file|grep -v "^#"  | grep -i "min_len" | awk '{print $2}')
local var4=$(cat $file|grep -v "^#"  | grep -i "min_days\|max_days\|min_len" | awk '{print $1 "->" $2}')

echo -e "\n[8] $title\n*file : $file"
if [ $var1 -ne 90 ] || [ $var2 -ne 1 ] || [ $var3 -ne 9 ] ; then
  echo -e "\n*[8-1] $nok\n$now\n$var4"
  echo "최대 또는 최소에 부합하지 않습니다. 최대만료일(90) 최소만료일(1) 패스워드 최소길이(9)"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[8-1] $ok\n$now\n$var4"
  echo "패스워드 설정 확인"
  ocnt=$((ocnt+1))
fi

line
}
num8 >> $result


## 9. 소유주가 없는 파일이거나 아무나 수정 가능한 파일 검색
num9 () {
local title="소유주가 없는 파일이거나 아무나 수정 가능한 파일 검색"

local var1=$(find /* -nouser -o -nogroup -type f 2> /dev/null |wc -l)
local var2=$(find /* -nouser -o -nogroup -type f 2> /dev/null)
local var3=$(find / -type f -not -path "/proc/*" -not -path "/sys/*" -perm -2 -exec ls -l {} \; | wc -l)
local var4=$(find / -type f -not -path "/proc/*" -not -path "/sys/*" -perm -2 -exec ls -l {} \;)

echo -e "\n[9] $title"
if [ $var1 -ne 0 ] ; then
  echo -e "\n*[9-1] $nok\n$now\n$var2"
  echo "소유주와 소유그룹이 없는 파일이 존재합니다. 삭제 또는 조치 필요"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[9-1] $ok\n$now\n"
  echo "파일이 발견 되지 않았습니다."
  ocnt=$((ocnt+1))
fi

if [ $var3 -ne 0 ] ; then
  echo -e "\n*[9-2] $nok\n$now\n$var4"
  echo "world write 권한 파일 확인, 권한 수정 필요"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[9-2] $ok\n$now\n"
  echo "world wirte 권한 파일 없음"
  ocnt=$((ocnt+1))
fi

line
}
num9 >> $result


## 10. host allow/deny 파일 확인
num10 () {
local file="/etc/hosts.deny"
local title="host allow/deny 파일 확인"

local var1=$(ls $file 2> /dev/null | wc -l)

echo -e "\n[10] $title\n*file : $file"
if [ $var1 -eq 1 ] ; then
  echo -e "\n*[10-1] $nok\n$now\n$var1"
  echo "TCP_WARRPERS 동작중, 확인 후 조치"
  ncnt=$((ncnt+1))
else
  echo -e "\n*[10-1] $ok\n"
  echo "firewalld  활성화 권장"
  ocnt=$((ocnt+1))
fi

line
}
num10 >> $result


## 11. 실행 서비스 목록 제공(불필요 서비스 중지)
num11 () {
local title="실행 서비스 목록 제공(불필요 서비스 중지)"

local var1=$(netstat -npltu)

echo -e "\n[11] $title"
echo -e "\n*[11-1] $now\n$var1"
echo "불필요 서비스 종료"

line
}
num11 >> $result


### template
#num () {
#local file=""
#local title=""
#
#local var1=""
#
#echo -e "\n[] $title\n*file : $file"
#if [] ; then
#  echo -e "\n*[] $nok\n$now\n$var"
#  echo ""
#else
#  echo -e "\n*[] $ok\n$now\n$var"
#  echo ""
#fi
#
#line
#}
#num >> $result


## total condition
printf "\n취약 : %d\n양호 : %d\n" "$ncnt" "$ocnt" >> $result 


## remvoe temp file
sed 's/^[ \t]*//' $result > ${result}_tmp
cat ${result}_tmp > $result
rm -f ${result}_tmp
