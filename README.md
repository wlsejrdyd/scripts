# 일일점검
[daily_system_chk_v0.3.sh]
서버에서 일일점검 스크립트를 실행하여 파일로 일주일간 데이터를 저장해서 관리할 수 있습니다.
"## Variables" 섹션을 조절하여 사용해보세요?
[daily_system_chk_v0.3.sh]: https://github.com/wlsejrdyd/scripts/blob/main/daily_system_chk_v0.3.sh


# 로컬백업
https://github.com/wlsejrdyd/scripts/blob/main/sync.sh
서버의 주요 디렉터리를 백업하고 일주일간 보관해보세요. 백업 디렉터리의 용량이 70%가 초과하면 동작하지않습니다.
역시 파일을 열어 "## Variables" 섹션을 수정하여 사용해보세요.

# 기본세팅
https://github.com/wlsejrdyd/scripts/blob/main/newvmstart_v1.2.sh
신규 VM을 생성한 후 root 로 SSH를 통해 서버에 접근하여 동작시키면 됩니다.
일반 계정을 생성하고 난수로 된 패스워드를 자동으로 입력해주며, SSH root 접근 비활성화. 변경한 SSH 포트를 추가할 수 있도록 firewalld 정책도 추가 할 수 있습니다.
