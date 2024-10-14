#!/bin/bash
# made by jdy

insert_file="/home/jindeokyong/20240328/team_code"
while IFS= read -r line; do
    deok0="$line"
    #read -p "Enter CODE : " deok0
    deok1=$(mysql -uroot -p'PASSWORD' DATABASE -e "select processId , processNumber  from ProcessNumberEntity pne where pne.processId in ( select processId from ProcessEntity pe where isOld = false and processType = 'Received' and processStatusType = 'Completed' and draftedAt > '2022-05-01 00:00:00' and draftedAt < '2022-12-31 23:23:59' and templateCode not in ('HH000001', 'HH000002', 'HH000003', 'HH000004',  'HH000050', 'BUY000039', 'MIS000037', 'GE0001', 'GE0002', 'kk000111') and submittedTeamId = '${deok0}' order by draftedAt ) order by createdAt ;")
    jdy4="/home/jindeokyong/20240328"
    deok2="${jdy4}/${deok0}.txt"
    echo -e "${deok1}" > ${deok2}
    sed -i '/processNumber/'d ${deok2}
    deok3=$(cat ${deok0}.txt | awk '{print $2}' | awk -F "-" '{print $2}')
    deok4=$(mysql -uroot -p'PASSWORD' DATABASE -e "select processId , processNumber, count(*) from ProcessNumberEntity pne where pne.processId in ( select processId from ProcessEntity pe where isOld = false and processType = 'Received' and processStatusType = 'Completed' and draftedAt > '2022-05-01 00:00:00' and draftedAt < '2022-12-31 23:23:59' and templateCode not in ('HH000001', 'HH000002', 'HH000003', 'HH000004',  'HH000050', 'BUY000039', 'MIS000037', 'GE0001', 'GE0002', 'kk000111') and submittedTeamId = '${deok0}'        order by draftedAt) order by createdAt ;" | awk '{print $3}' | grep -v "count")

    for i in ${deok3}
    do
        #echo "i : $i"
        sed -i "s@\-${i}\$@\-00000\$@g" ${deok2}
    done
    deok5=$(cat ${deok0}.txt | awk '{print $2}' | awk -F "-" '{print $2}')
    awk '{split($2, arr, "-"); num = $2 + NR + 1 - 1; new_num = sprintf("%05d", num); print $1, arr[1] "-" new_num}' ${deok0}.txt > $deok0_1.txt && mv $deok0_1.txt $deok0.txt

    for ((jdy1=1; jdy1<=deok4; jdy1++)); do
        #echo "jdy1: $jdy1"
        sed -n ${jdy1}p ${deok2} > ${jdy4}/${deok0}_$jdy1.txt
        jdy2=$(cat ${jdy4}/${deok0}_$jdy1.txt | awk '{print $2}')
        jdy3=$(cat ${jdy4}/${deok0}_$jdy1.txt | awk '{print $1}')
        mysql -uroot -p'PASSWD' DATABASE -e "update ProcessNumberEntity set processNumber='${jdy2}' where processId='${jdy3}';"
    done

    mysql -uroot -p'PASSWD' DATABASE -e "select processId , processNumber  from ProcessNumberEntity pne where pne.processId in ( select processId from ProcessEntity pe where isOld = false and processType = 'Received' and processStatusType = 'Completed' and draftedAt > '2022-05-01 00:00:00' and draftedAt < '2022-12-31 23:23:59' and templateCode not in ('HH000001', 'HH000002', 'HH000003', 'HH000004',  'HH000050', 'BUY000039', 'MIS000037', 'GE0001', 'GE0002', 'kk000111') and submittedTeamId = '${deok0}' order by draftedAt ) order by createdAt ;" | tee ${jdy4}/${deok0}.result
    rm -rf ${jdy4}/${deok0}_*

done < "$insert_file"