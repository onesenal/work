#!/bin/bash

# 파일 경로
file_path="list.txt"

# 현재 타임스탬프
TSTMP=$(date +%m%d)

# 파일로부터 한 줄씩 읽어와 처리
while read -r line; do
    # 해당 줄을 사용하여 kubectl 명령어 실행 결과를 배열에 저장
    A=($(kubectl get pod -A | grep "$line" | awk '{print $2}'))
    B=($(kubectl get pod -A | grep "$line" | awk '{print $1}'))
    
    # sop_logs 디렉토리 생성 (이미 있으면 무시)
    mkdir -p export_logs
    
    # 각 결과값에 대해 로그 수집 및 저장
    for (( i = 0; i < ${#A[@]}; i++ )); do
        pod_name="${A[i]}"
        namespace="${B[i]}"

        # 로그 파일 경로 생성
        log_file="export_logs/$(date +%m%d)_${pod_name}_${namespace}.log"
        
        # 로그 수집
        kubectl logs "$pod_name" -n "$namespace" >> "$log_file"
    done

    # 여기에 각 줄에 대한 추가 작업을 수행
done < "$file_path"

tar -cvzf $(date +%m%d).tar.gz ./export_log/*
curl -v -u psmdocker:PCadmin@00 --upload-file *.tar.gz http://172.31.66.8:8081/repository/jenkins1/cho/export_log