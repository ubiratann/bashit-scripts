#!/bin/bash

#generating secrets by namespace
function generate_secrets_files(){
    local NAMESPACE=$1

    local secrets=$(kubectl get secrets --no-headers -n $NAMESPACE | grep opaque | awk '{print $1}')
    if [ ! -z "$secrets" ];
    then
        for secret in $secrets; 
        do 
            echo "Current secret: $secret"
            kubectl get secrets/$secret -o yaml -n $NAMESPACE | yq '.data.* |=  (@base64d | from_yaml)' | yq '.data' > teste
        done
    else
        echo "No secret found for namespace: $NAMESPACE"
    fi
    secrets=""

}
function main(){
    #file with namespaces
    local namespace_file=$1
    
    download_yq
    
    echo -e "\n"
    while IFS= read -r line || [ -n "$line" ]
    do
        echo "Getting files from namespace: $line"
        generate_secrets_files $line
        echo -e "\n"
    done < "$namespace_file"
}

main "$1"