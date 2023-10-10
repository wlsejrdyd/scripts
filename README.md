## 일일점검

* [일일점검 (daily_system_chk_v0.3.sh)](https://github.com/wlsejrdyd/scripts/blob/main/daily_system_chk_v0.3.sh)
  * 7일 보관
  * 주요 보안파일 변조 확인 (월)
  * 디스크, 메모리, CPU, login history 기록 등
  * Variables 섹션 수정하여 사용

## 패스워드난수 설정

* [난수설정 (randompw_v0.1.sh)](https://github.com/wlsejrdyd/scripts/blob/main/randompw_v0.1.sh)
  * UID 500 ~ 10000 사이 USER를 grep 해서 목록으로 보여준다. (선택지)
  * 대/소문자, 특수문자, 숫자 포함한 10자의 패스워드를 설정해줌
  * 항목에 따른 계정을 입력시 stdin 되어 생성 된 패스워드로 바로 변경진행 됨
  * root 계정은 항목에서 제외시켰지만 입력하면 변경가능
  * 간혹 오작동하여 실패하지만 다시 동작하면 됨....
  * logger 를 이용하여 원격 로그서버로 전송도 가능함. (분실시 백업용도)
