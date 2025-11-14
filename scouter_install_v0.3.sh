#!/bin/bash
#made by jindeokyong

# 한글 출력 깨짐 방지 설정
if locale -a | grep -q "ko_KR.utf8"; then
    export LANG=ko_KR.utf8
    export LC_ALL=ko_KR.utf8
elif locale -a | grep -q "en_US.utf8"; then
    export LANG=en_US.utf8
    export LC_ALL=en_US.utf8
else
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8
fi

echo "[NOTICE] 스카우터 설치 스크립트를 실행 합니다. "
sc_svcid="apm"
sc_userhome="/home/${sc_svcid}"
sc_dir="${sc_userhome}/scouter"
jdk_path="${sc_userhome}/jdk"

if [ $(id -u) -ne "0" ] ; then
  echo "[WARNING] root 계정으로 실행 해주시길 바랍니다."
  exit 1
fi

echo -e "[NOTICE] 설치 디렉토리는 ${sc_dir} 이며, 서비스 계정은 ${sc_svcid} 입니다. \n[NOTICE] 스크립트와 패키지 파일을 미리 준비해주세요."
  echo "확인 하셨으면 엔터를 입력해주세요."
  read
  sleep 1

## 계정 생성
if [ $(cat /etc/passwd | grep $sc_svcid | wc -l) -eq 0 ] ; then
  echo "[INFO] 생성 된 서비스 계정이 없어 계정을 생성합니다."
  useradd -c "Scouter Service Account ID" -s /sbin/nologin $sc_svcid
  id $sc_svcid
else
  echo "[INFO] 이미 계정이 있습니다."
  id $sc_svcid
fi

## 디렉터리 및 소스파일 압축 해제
if [ ! -d "$sc_dir" ] ;
  then
    mkdir -p $sc_userhome
    echo "[INFO] $sc_dir 경로에 스카우터를 찾을 수 없습니다."
    echo "[INFO] 압축해제를 위해 파일의 경로를 검색 하시겠습니까?"
    while true; do
      read -p "디스크용량이 커서 검색이 오래걸릴 것 같다면 n 선택 후 진행 해주세요. (y/n) : " var
      if [ -z "$var" ] ; then
        continue
      else
        break
      fi
    done
    case $var in
      y | Y )
        find1=`find /* -type f -name "nx-scouter*" -exec echo "압축 파일 경로 : {}" \;`
	echo "${find1}"
        echo -n "위 경로를 참고하여 압축 파일 경로 입력 해주세요. : "
        read path
	echo "[INFO] $sc_userhome 경로로 압축 해제 중입니다."
        tar xvfz $path -C $sc_userhome > /dev/null
	chown -R $sc_svcid:$sc_svcid $sc_userhome
        if [ $? -eq 0 ] ;
        then
          echo "[INFO] 압축 해제가 성공 하였습니다."
          ls -l $sc_userhome
        else
          echo "[WARNING] 압축 해제가 실패 하였습니다."
        fi
        ;;
      n | N )
        echo -n "절대경로 포함 파일명까지 수동으로 입력 해주세요. : "
        read path
	echo "[INFO] $sc_userhome 경로로 압축 해제 중입니다."
        tar xvfz $path -C $sc_userhome > /dev/null
	chown -R $sc_svcid:$sc_svcid $sc_userhome
        if [ $? -eq 0 ] ;
        then
          echo "[INFO] 압축 해제가 성공 하였습니다."
          ls -l $sc_userhome
        else
          echo "[WARNING] 압축 해제가 실패 하였습니다."
        fi
        ;;
    esac
else
  echo -e "[NOTICE] $sc_dir 경로에 스카우터가 설치되어 있습니다.\n다시 압축해제를 원하실 경우$sc_dir 삭제 후 진행해주세요.\n재설치를 목적으로 하신다면 반드시 삭제 후 다시 진행해야 합니다."
fi

## 스카우터 설치 진행
while true ; do
  echo -e "\n[SELECT]\n(1) Configuration Scouter Server\n(2) Configuration Scouter agent.host\n(3) Configuration Scouter agent.java\n(0) exit"
  read -p "(0~3) : " var
    case $var in
      1)
        echo "[INFO] scouter-server 설정을 시작 합니다."
	if [ ! -f "$sc_dir/server/conf/scouter.conf" ] ; then
	  echo "[WARNING] 설정파일이 없습니다."
	fi
	read -p "서버 명칭을 입력 해주세요 (ex : nx-scouter-server) : " serverid
	  sed -i "s@serverid@$serverid@g" $sc_dir/server/conf/scouter.conf && sleep 1
	  sed -i "s@scdir@$sc_dir@g" $sc_dir/server/conf/scouter.conf && sleep 1
	  sed -i "s@jdkpath@$jdk_path@g" $sc_dir/server/startup.sh && sleep 1
        echo -e "[Unit]
Description=Scouter-Server Service (v1.0)
After=network.target

[Service]
WorkingDirectory=$sc_dir/server
User=$sc_svcid
Group=$sc_svcid
ExecStart=$jdk_path/bin/java -Xmx512m -classpath ./scouter-server-boot.jar scouter.boot.Boot ./lib
ExecStop=/usr/bin/rm -f $sc_dir/server/*.scouter
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/scouter-server.service
        echo "[INFO] scouter-server 를 시작 합니다."
	systemctl daemon-reload
	systemctl enable --now scouter-server
	systemctl status scouter-server
	echo -e "[NOTICE] (IN BOUND) 6100 TCP/UDP 허용 정책 등록 필요합니다."
	sleep 1
	continue
        ;;
      2)
        echo "[INFO] agent.host 설정을 시작 합니다."
	if [ ! -f "$sc_dir/agent.host/conf/scouter.conf" ] ; then
	  echo "[WARNING] 설정파일이 없습니다."
	fi
	read -p "scouter-server의 IP를 입력 해주세요 (ex : `ip -br addr | grep UP | grep -oP "\d+\.\d+\.\d+\.\d+"`) : " serverip
	  sed -i "s@serverip@$serverip@g" $sc_dir/agent.host/conf/scouter.conf && sleep 1
	  sed -i "s@jdkpath@$jdk_path@g" $sc_dir/agent.host/host.sh && sleep 1
	echo -e "[Unit]
Description=Scouter-Host Service (v1.1)
After=network.target

[Service]
WorkingDirectory=$sc_dir/agent.host
User=$sc_svcid
Group=$sc_svcid
ExecStart=$jdk_path/bin/java -classpath ./scouter.host.jar scouter.boot.Boot ./lib
ExecStop=/usr/bin/rm -f $sc_dir/agent.host/*.scouter
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/scouter-host.service
        echo "[INFO] scouter-host 를 시작 합니다."
        systemctl daemon-reload
	systemctl enable --now scouter-host
	systemctl status scouter-host
	sleep 1
	continue
        ;;
      3)
        echo "[INFO] agent-java 설정을 시작 합니다."
        echo "[NOTICE] 서버내 tomcat intance 가 여러개 존재 한다면 반복 설치를 해야합니다."
	while true ; do
	  echo "[INFO] tomcat setenv.sh 파일 경로를 검색 하시겠습니까?"
          read -p "디스크용량이 커서 검색이 오래걸릴 것 같다면 n 선택 후 진행 해주세요. (y/n) : " var
	  if [ -z "$var" ] ; then
	    continue
	  else
	    break
	  fi
	done
	if [ $var == "y" ] ; then
	  find1=$(find /* -type f -name "catalina.sh" | while read file ; do echo "${file/catalina.sh/setenv.sh}" ;done)
	  if [ -z "${find1}" ] ; then
            echo "[WARNING] 설치 되어있는 tomcat 위치를 찾을 수 없습니다."
	    continue
	  else
	    echo -e "[NOITCE] setenv.sh 파일 경로\n${find1}"
          fi
        else
	  echo -e "[NOTICE] 수동입력 방식으로 선택하셨습니다. \"setenv.sh\" 파일이름까지 절대경로로 입력해주시기 바랍니다."
        fi
	while true; do
          if [ "${var}" == "c" ] || [ "${var}" == "C" ] ; then
	    echo -e "\n[INFO] 선택화면으로 돌아갑니다."
            break 
          fi
	  echo -e "[WARNING] 지금 등록할 값은 모니터링에 등록 할 톰캣의 object 이름입니다.\n[WARNING] 해당값은 중복되지 않아야 합니다.\n[WARNING] 중복되는 경우 덮어쓰여지게 됩니다."
	  read -p "(ex : nx-was-01) : " objname
	  cp -ar $sc_dir/agent.java/conf/scouter.conf $sc_dir/agent.java/conf/scouter.${objname}.conf
	  sed -i "s@objtmpname@$objname@g" $sc_dir/agent.java/conf/scouter.${objname}.conf && sleep 1
	  if [ -f ${sc_dir}/agent.host/conf/scouter.conf ] ; then
	    echo "[INFO] Server IP로 사용했던 IP는 $(grep "ip" ${sc_dir}/agent.host/conf/scouter.conf | cut -d '=' -f 2) 입니다."
	  fi
	  read -p "scouter-server(collector)의 IP를 입력 해주세요 : " serverip
            sed -i "s@serverip@$serverip@g" $sc_dir/agent.java/conf/scouter.${objname}.conf && sleep 1
	  read -p "setenv.sh 파일에 모니터링을 등록을 설정을 추가 하시겠습니까? (y/n) : " var
	  case $var in
	    y | Y )
              read -p "setenv.sh 절대경로 입력 : " path
	      echo "[INFO] $path 파일에 설정을 추가 합니다."
	      if [ -f $path ] ; then
	        cp -ar $path $path.$(date +'%Y-%m-%d')
	      else
		touch $path
	      fi
	      comm1="$(cat $path | grep -i scouter | wc -l)"
	      if [ $comm1 == "0" ] ; then
                cat << EOF >> $path
#===========================================================
#Scouter Setting
#===========================================================
SCOUTER_AGENT_DIR=/home/$sc_svcid/scouter/agent.java
JAVA_OPTS="\${JAVA_OPTS} -javaagent:\${SCOUTER_AGENT_DIR}/scouter.agent.jar"
JAVA_OPTS="\${JAVA_OPTS} -Dscouter.config=\${SCOUTER_AGENT_DIR}/conf/scouter.$objname.conf"
EOF
                echo "[NOTICE] setenv.sh 파일 owner 확인 해주세요."
		ls -l $path
              else
	        echo "[WARNING] 파일에 설정이 되어있어 설정을 취소합니다."
	      fi 
	      echo "[NOTICE] scouter-host 서비스를 재시작 해주세요."
	      ;;
	    n | N | * ) 
	      echo "[WARNING] 추가하지 않으면 모니터링 불가능합니다."
	      ;;
          esac
          read -p "다른 톰캣 설정을 진행하시려면 \"enter\", 설치를 종료하시려면 \"c\"를 입력해주세요 :" var
	done
        ;;
      0)
	echo "[INFO] scouter client 기본 계정과 패스워드는 admin, admin 입니다."
	echo "[INFO] 스크립트 종료"
        exit 0
        ;;
    esac
done
