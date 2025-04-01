#!/bin/bash
export KUBECONFIG=/var/lib/jenkins/.kube/kubeconfig_env-b-uat-eks
export envno=b
unset http_proxy https_proxy no_proxy NO_PROXY HTTP_PROXY HTTPS_PROXY

directories=("[directory1]" "[directory2]" "[directory3]" "[directory4]")

while true; do
    for directory in "${directories[@]}"; do
        find "$directory" -name "*" -mtime +14 -exec rm {} \;
        
        TSTMP=$(date +%Y-%m-%d)
        
        echo "=======================================" >> "$directory/$TSTMP"
        echo "| UTC:$(TZ=UTC date +'%m-%d %H:%M:%S') KST:$(TZ=Asia/Seoul date +'%m-%d %H:%M:%S')|" >> "$directory/$TSTMP"
        echo "=======================================" >> "$directory/$TSTMP"
        
        if [[ $directory == *"AUTH_POD_STATUS"* ]]; then
            kubectl get pods -o wide -n [namespace.name] -o custom-columns="NAMESPACE:.metadata.namespace,POD_NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase,RESTARTS:.status.containerStatuses[*].restartCount,NODE:.spec.nodeName" >> "$directory/$TSTMP"
        elif [[ $directory == *"RT_POD_STATUS"* ]]; then
            kubectl get pods -o wide -n [namespace.name] -o custom-columns="NAMESPACE:.metadata.namespace,POD_NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase,RESTARTS:.status.containerStatuses[*].restartCount,NODE:.spec.nodeName" >> "$directory/$TSTMP"
        elif [[ $directory == *"AUTH_HPA"* ]]; then
            kubectl get hpa -n [namespace.name] >> "$directory/$TSTMP"
        elif [[ $directory == *"RT_HPA"* ]]; then
            kubectl get hpa -n [namespace.name] >> "$directory/$TSTMP"
        fi
    done

    sleep 60
done &
