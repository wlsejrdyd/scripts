#!/bin/bash
# made by jindeokyong

echo "[NOTICE] 스카우터 설치 스크립트를 실행 합니다. 문의 사항은 별도 연락 부탁드립니다."
sc_dir="/app/scouter"
sc_infotxt="/tmp/info_scouter.txt"
sc_svcid="scoutersvc"

if [ $(id -u) -ne "0" ] ; then
  echo "[WARNING] root 계정으로 실행 해주시길 바랍니다."
  exit 1
fi

echo "[NOTICE] 설치 디렉토리는 /app/scouter 로 \"고정\" 입니다."
  echo "충분히 이해 하셨으면 엔터를 눌러주세요."
  read
  sleep 1

## 계정 생성
if [ $(cat /etc/passwd | grep $sc_svcid | wc -l) -eq 0 ] ; then
  echo "[INFO] 서비스 계정을 생성 합니다."
  useradd -c "Scouter Service Account ID" -s /sbin/nologin $sc_svcid
else
  echo "[INFO] 이미 계정이 있습니다."
fi

## 디렉터리 및 소스파일 압축 해제
if [ ! -d "/app/scouter" ] ;
  then
    echo "[INFO] /app 경로에 파일이 존재 하지 않습니다. 디렉터리를 만듭니다."
    mkdir -p /app
    find1=`find /* -type f -name "jdy-scouter*" -exec echo "압축 파일 경로 : {}" \;`
    echo "$find1"
    read -p "/app 경로에 압축 해제 하시겠습니까? (y/n) : " var
    case $var in
      y )
          echo -n "압축 파일 경로 입력 해주세요. ($find1) : "
          read path
          tar xvfz $path -C /app/
          chown -R $sc_svcid:$sc_svcid $sc_dir
          if [ $? -eq 0 ] ;
          then
            echo "[INFO] 압축 해제가 성공 하였습니다."
            ls -l /app
          else
            echo "[WARNING] 압축 해제가 실패 하였습니다."
          fi
          ;;
      n )
    esac
  else
    echo "[INFO] 디렉터리가 이미 존재 합니다, 설치를 진행 합니다."
    sleep 2
fi

## 스카우터 설치 진행
while true ; do
  echo -e "[SELECT]\n(1) Configuration Scouter Server\n(2) Configuration Scouter agent.host\n(3) Configuration Scouter agent.java\n(0) exit"
  read -p "(0~3) : " var
    case $var in
      1)
        echo "[INFO] Scouter-Server 설정을 시작 합니다."
        if [ ! -f "$sc_dir/server/conf/scouter.conf" ] ; then
          echo "[WARNING] 설정파일이 없습니다."
        fi
        read -p "사용하실 Scouter-Server 이름을 입력 해주세요 (ex : jdy-scouter-server-01) : " serverid
          sed -i "s@serverid@$serverid@g" $sc_dir/server/conf/scouter.conf && sleep 1
        find $sc_dir/server -type f -name "scouter.conf" -exec echo "==== PATH : {} ==== $(date)" \; -exec cat {} \; | grep -v "^#\|^$" >> $sc_infotxt
        echo -e "[Unit]
Description=Scouter Server Service
After=network.target

[Service]
WorkingDirectory=$sc_dir/server
User=$sc_svcid
Group=$sc_svcid
ExecStart=/app/jdk/bin/java -Xmx512m -classpath ./scouter-server-boot.jar scouter.boot.Boot ./lib
ExecStop=/usr/bin/rm -f *.scouter
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/scouter-server.service
        find /usr/lib/systemd/system/ -name "scouter-server.service" -exec echo "==== PATH : {} ==== $(date)" \; -exec cat {} \; >> $sc_infotxt
        systemctl daemon-reload
        systemctl enable --now scouter-server
        echo "==== scouter-server.service ==== $(date)" >> $sc_infotxt
        systemctl status scouter-server | head -10 >> $sc_infotxt
        echo "[INFO] Scouter-Server 설정이 완료 되었습니다. 방화벽(firewalld) 설정을 진행 합니다."
        if [ $(systemctl is-active firewalld) == "inactive" ] ; then
          echo "[WARNING] 방화벽 실행 후 가능합니다."
          continue
        fi
        firewall-cmd --list-all
        firewall-cmd --permanent --add-port=6100/tcp
        firewall-cmd --permanent --add-port=6100/udp
        firewall-cmd --reload
        firewall-cmd --list-all
        echo "[INFO] 방화벽 설정이 완료 되었습니다. (6100 TCP/UDP 허용 정책 필요)"
        sleep 1
        continue
        ;;
      2)
        echo "[INFO] Agent-Host 설정을 시작 합니다."
        if [ ! -f "$sc_dir/agent.host/conf/scouter.conf" ] ; then
          echo "[WARNING] 설정파일이 없습니다."
        fi
        read -p "Scouter-Server의 IP를 입력 해주세요 (ex : `ip -br addr | grep UP | grep -oP "\d+\.\d+\.\d+\.\d+"`) : " serverip
          sed -i "s@serverip@$serverip@g" $sc_dir/agent.host/conf/scouter.conf && sleep 1
        find $sc_dir/agent.host -type f -name "scouter.conf" -exec echo "==== PATH : {} ==== $(date)" \; -exec cat {} \; | grep -v "^#\|^$" >> $sc_infotxt
        echo -e "[Unit]
Description=Scouter Host Service
After=network.target

[Service]
WorkingDirectory=$sc_dir/agent.host
User=$sc_svcid
Group=$sc_svcid
ExecStart=/app/jdk/bin/java -classpath ./scouter.host.jar scouter.boot.Boot ./lib
ExecStop=/usr/bin/rm -f *.scouter
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/scouter-host.service
        find /usr/lib/systemd/system/ -name "scouter-host.service" -exec echo "==== PATH : {} ==== $(date)" \; -exec cat {} \; >> $sc_infotxt
        systemctl daemon-reload
        systemctl enable --now scouter-host
        echo "==== scouter-host.service ==== $(date)" >> $sc_infotxt
        systemctl status scouter-host | head -10 >> $sc_infotxt
        sleep 1
        continue
        ;;
      3)
        echo "[INFO] Agent-Java 설정을 시작 합니다."
        echo "[NOTICE] object 이름은 중복되지 않아야 합니다."
        read -p "(ex : Project1-WAS-01) : " objname
          sed -i "s@objtmpname@$objname@g" $sc_dir/agent.java/conf/scouter.conf && sleep 1
        echo "[INFO] Server IP로 사용했던 IP는 $serverip 입니다.."
        read -p "Scouter-Server의 IP를 입력 해주세요 : " serverip
          sed -i "s@serverip@$serverip@g" $sc_dir/agent.java/conf/scouter.conf && sleep 1
        find $sc_dir/agent.java -type f -name "scouter.conf" -exec echo "==== PATH : {} ==== $(date)" \; -exec cat {} \; | grep -v "^#\|^$" >> $sc_infotxt
        echo -e "\n[NOTICE]\n1. tomcat 재실행이 필요 합니다.\n2. setenv.sh, startup.sh, catalina.sh 중 선택해서 하나만 등록 하면 됩니다.\n3. 동작을 위해 scouter-host 를 재실행 해야 합니다."
        sleep 1
        find /* -type f -name "catalina.sh" | while read file ; do echo "${file/catalina.sh/setenv.sh}" ;done
        read -p "setenv.sh 파일 맨 마지막 줄에 Scouter 설정을 추가 하시겠습니까? (y/n) : " var
        case $var in
          y | Y )
            read -p "[INFO] setenv.sh 절대 경로 입력 : " path
            echo "[INFO] $path 파일에 설정을 추가 합니다."
            cp -ar $path $path.$(date +'%Y-%m-%d')
            echo '#===========================================================
#Scouter Setting
#===========================================================
export SCOUTER_AGENT_DIR=/app/scouter/agent.java
export JAVA_OPTS="$JAVA_OPTS -javaagent:${SCOUTER_AGENT_DIR}/scouter.agent.jar"
export JAVA_OPTS="$JAVA_OPTS -Dscouter.config=${SCOUTER_AGENT_DIR}/conf/scouter.conf"' >> $path
            ;;
          n | N | * )
            echo "need a continue?"
            ;;
        esac
        echo "[INFO] scouter-host 서비스를 재시작 합니다."
        systemctl restart scouter-host
        continue
        ;;
      0)
        echo "[INFO] scouter client 기본 계정과 패스워드는 admin, admin 입니다."
        echo "[INFO] 스크립트 종료"
        exit 0
        ;;
    esac
done
 
