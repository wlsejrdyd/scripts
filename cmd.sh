/etc/profile.d 경로에 넣어준다.

# CMD Log
HISTTIMEFORMAT="%Y-%m-%d [%H:%M:%S] "
export HISTTIMEFORMAT
export MALLOC_CHECK_=0
function history_to_syslog() {
        declare USERCMD
        USERCMD=$(fc -ln -0 2>/dev/null|sed 's/\t //')
        declare PP
        if [ "$USER" == "root" ]
        then
                PP="]#"
        else
                PP="]$"
        fi
        if [ "$USERCMD" != "$OLD_USERCMD" ]
        then
                if [ "$(echo $LANG)" == "C" ]
                then
        logger -p local4.notice -t bash -i "$USER$(who am i|awk '{print $6}'):$PWD$PP $USERCMD"
                else
        logger -p local4.notice -t bash -i "$USER$(who am i|awk '{print $5}'):$PWD$PP $USERCMD"
                fi
        fi
        OLD_USERCMD=$USERCMD
        unset USERCMD PP
}
trap 'history_to_syslog' DEBUG
