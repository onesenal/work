#!/bin/bash
# 초기 구성
export KUBECONFIG=/var/lib/jenkins/.kube/kubeconfig_env-c-uat-eks; export envno=c
unset http_proxy https_proxy no_proxy NO_PROXY HTTP_PROXY HTTPS_PROXY

export TSTMP=$(date)

# TSTMP로부터 년, 월, 일 추출
YEAR=$(date -d "$TSTMP" +%Y)
#YEAR=2023
MONTH=$(date -d "$TSTMP" +%m)
#MONTH=09
DAY=$(date -d "$TSTMP" +%d)
#DAY=05
TIME=$(date -d "$TSTMP" +%H%M)
HOUR=$(date -d "$TSTMP" +%H)
#AUTH
# ex) Script 위치: /var/lib/jenkins/cho/uat_c/artifact_logs/
rm -rf /var/lib/jenkins/cho/uat_c/artifact_logs/[directory1]/[directory2]
mkdir /var/lib/jenkins/cho/uat_c/artifact_logs/[directory1]/[directory2]
cd /var/lib/jenkins/cho/uat_c/artifact_logs/[directory1]/[directory2]

aws s3 cp s3://[bucket.name]/[directory.name]/AWSLogs/072551541449/elasticloadbalancing/ap-northeast-2/${YEAR}/${MONTH}/${DAY} . --recursive

for i in `ls -1rt`; do gunzip $i; echo "$i --------------------"; done

mkdir [directory3]_${DAY}_${MONTH}_${YEAR}; for i in `ls -1rt`; do cat ${i} >> APIGW_LB_${DAY}_${MONTH}_${YEAR}/ALL_TRANSACTIONS_${DAY}_${MONTH}_${YEAR} ; echo "0------------------------------- $i"; done

cd [directory3]_${DAY}_${MONTH}_${YEAR}

cat ALL_TRANSACTIONS_${DAY}_${MONTH}_${YEAR} | awk -F" " '{print $14}' | awk -F"?" '{print $1}' | awk -F"/" '{print $4"/"$5"/"$6}'|sort -n | uniq > API_LIST

for i in `cat API_LIST`; do filename=`echo $i | awk -F"/" '{print $3}'`; cat ALL_TRANSACTIONS_${DAY}_${MONTH}_${YEAR} | grep ${i} > ${filename}.access.log ; echo "---- ${filename} ----- ${i}"; done

cd ..

tar -zcvf [directory3]_${YEAR}_${MONTH}_${DAY}_${TIME}_FINAL.tar.gz [directory3]_${DAY}_${MONTH}_${YEAR}

curl -v -u [repo.id]:[repo.passwd] --upload-file [directory3]_${YEAR}_${MONTH}_${DAY}_${TIME}_FINAL.tar.gz http://[repo.ip]]:[repo.port]/[repo.save.directory]

echo -e "\n\n ------------------"
echo "________________________________________________________________________________________________"
echo "GET YOUR LOG FILE @ http://[repo.ip]]:[repo.port]/[directory3]_${YEAR}_${MONTH}_${DAY}_${TIME}_FINAL.tar.gz"
echo "________________________________________________________________________________________________"

#RT
rm -rf /var/lib/jenkins/cho/uat_c/artifact_logs/TEMP/APIGW_LB_LOGS_TEMP
mkdir /var/lib/jenkins/cho/uat_c/artifact_logs/TEMP/APIGW_LB_LOGS_TEMP
cd /var/lib/jenkins/cho/uat_c/artifact_logs/TEMP/APIGW_LB_LOGS_TEMP

aws s3 cp s3://accesslogs-uatc/prefix-rt/AWSLogs/072551541449/elasticloadbalancing/ap-northeast-2/${YEAR}/${MONTH}/${DAY} . --recursive

for i in `ls -1rt`; do gunzip $i; echo "$i --------------------"; done

mkdir APIGW_LB_${DAY}_${MONTH}_${YEAR}; for i in `ls -1rt`; do cat ${i} >> APIGW_LB_${DAY}_${MONTH}_${YEAR}/ALL_TRANSACTIONS_${DAY}_${MONTH}_${YEAR} ; echo "0------------------------------- $i"; done

cd APIGW_LB_${DAY}_${MONTH}_${YEAR}

cat ALL_TRANSACTIONS_${DAY}_${MONTH}_${YEAR} | awk -F" " '{print $14}' | awk -F"?" '{print $1}' | awk -F"/" '{print $4"/"$5"/"$6}'|sort -n | uniq > API_LIST


for i in `cat API_LIST`; do filename=`echo $i | awk -F"/" '{print $3}'`; cat ALL_TRANSACTIONS_${DAY}_${MONTH}_${YEAR} | grep ${i} > ${filename}.access.log ; echo "---- ${filename} ----- ${i}"; done

cd ..

tar -zcvf APIGW_LB_${YEAR}_${MONTH}_${DAY}_${TIME}_FINAL.tar.gz APIGW_LB_${DAY}_${MONTH}_${YEAR}

curl -v -u psmdocker:PCadmin@00 --upload-file APIGW_LB_${YEAR}_${MONTH}_${DAY}_${TIME}_FINAL.tar.gz http://172.31.66.8:8081/repository/jenkins1/cho/artifact_alb_logs/uatc/rt/APIGW_LB_LOGS/

echo -e "\n\n ------------------"
echo "________________________________________________________________________________________________"
echo "GET YOUR LOG FILE @ http://172.31.66.8:8081/repository/jenkins1/cho/artifact_logs/APIGW_LB_LOGS/APIGW_LB_${YEAR}_${MONTH}_${DAY}_${TIME}_FINAL.tar.gz"
echo "________________________________________________________________________________________________"