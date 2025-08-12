#!/bin/bash
# made by jindeokyong

echo "[NOTICE] 스카우터 설치 스크립트를 실행 합니다. 문의 사항은 별도 연락 부탁드립니다." && sleep 1
dir1="/app/scouter"
infotxt="/tmp/info_scouter.txt"
svcid="scoutersvc"

if [ $(id -u) -ne "0" ] ; then
        echo "[WARNING] root 계정으로 실행 해주시길 바랍니다."
        exit 1
fi

read -p "[NOTICE] 설치 디렉토리는 /app/scouter 로 \"고정\" 입니다. (y/n) : " var1
case $var1 in
  y)
    echo "동의 하신다면 엔터를 눌러주세요."
    read
    echo ""
    ;;
  *)
    echo "동의 하신다면 엔터를 눌러주세요."
    read
    echo ""
    exit 1
    ;;
esac

## 계정 생성
if [ $(cat /etc/passwd | grep $svcid | wc -l) -eq 0 ] ; then
  echo "[INFO] 서비스 계정을 생성 합니다."
  useradd -c "Scouter Service Account ID" -s /sbin/nologin $svcid
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
    read -p "/app 경로에 압축 해제 하시겠습니까? (y/n) : " var2
    case $var2 in
      y )
          echo -n "압축 파일 경로 입력 해주세요. ($find1) : "
          read path1
          tar xvfz $path1 -C /app/
          chown -R $svcid:$svcid $dir1
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
    echo "[NOTICE] 디렉터리가 이미 존재 합니다, 설치를 진행 합니다."
    sleep 2
fi

## 스카우터 설치 진행
while true ; do
  echo -e "[SELECT]\n(1) Configuration Scouter Server\n(2) Configuration Scouter agent.host\n(3) Configuration Scouter agent.java\n(0) exit"
  read -p "(0~3) : " var3
    case $var3 in
      1)
        echo "[INFO] Scouter-Server 설정를 시작 합니다."
        if [ ! -f "$dir1/server/conf/scouter.conf" ] ; then
          echo "[WARNING] 설정파일이 없습니다."
        fi
        read -p "사용하실 Scouter-Server 이름을 입력 해주세요 (ex : jdy-scouter-server-01) : " serverid1
        sed -i "s@serverid@$serverid1@g" $dir1/server/conf/scouter.conf
        find $dir1/server -type f -name "scouter.conf" -exec echo "==== PATH : {} ==== $(date)" \; -exec cat {} \; | grep -v "^#\|^$" >> $infotxt
        echo -e "[Unit]
Description=Scouter Server Service
After=network.target

[Service]
WorkingDirectory=/app/scouter/server
User=$svcid
Group=$svcid
ExecStart=/app/jdk/bin/java -Xmx512m -classpath ./scouter-server-boot.jar scouter.boot.Boot ./lib
ExecStop=/usr/bin/rm -f *.scouter
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/scouter-server.service
        find /usr/lib/systemd/system/ -name "scouter-server.service" -exec echo "==== PATH : {} ==== $(date)" \; -exec cat {} \; >> $infotxt
        systemctl daemon-reload
        systemctl enable --now scouter-server
        echo "==== scouter-server.service ==== $(date)" >> $infotxt
        systemctl status scouter-server | head -10 >> $infotxt
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
        continue
        ;;
      2)
        echo "[INFO] Agent-Host 설정를 시작 합니다."
        if [ ! -f "$dir1/agent.host/conf/scouter.conf" ] ; then
          echo "[WARNING] 설정파일이 없습니다."
        fi
        read -p "Scouter-Server의 IP를 입력 해주세요 (ex : `ip -br addr | grep UP | grep -oP "\d+\.\d+\.\d+\.\d+"`) : " serverip1
        sed -i "s@serverip@$serverip1@g" $dir1/agent.host/conf/scouter.conf
        find $dir1/agent.host -type f -name "scouter.conf" -exec echo "==== PATH : {} ==== $(date)" \; -exec cat {} \; | grep -v "^#\|^$" >> $infotxt
        echo -e "[Unit]
Description=Scouter Host Service
After=network.target

[Service]
WorkingDirectory=$dir1/agent.host
User=$svcid
Group=$svcid
ExecStart=/app/jdk/bin/java -classpath ./scouter.host.jar scouter.boot.Boot ./lib
ExecStop=/usr/bin/rm -f *.scouter
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/scouter-host.service
        find /usr/lib/systemd/system/ -name "scouter-host.service" -exec echo "==== PATH : {} ==== $(date)" \; -exec cat {} \; >> $infotxt
        systemctl daemon-reload
        systemctl enable --now scouter-host
        echo "==== scouter-host.service ==== $(date)" >> $infotxt
        systemctl status scouter-host | head -10 >> $infotxt
        continue
        ;;
      3)
        echo "[INFO] Agent-Java 설정를 시작 합니다."
        echo "준비중"
        #obj_name=objtmpname
        #net_collector_ip=serverip
        continue
        ;;
      0)
        echo "[INFO] 스크립트 종료"
        exit 0
        ;;
    esac
done
