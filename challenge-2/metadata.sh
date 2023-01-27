#!/bin/bash

instance=$1
proj=$2
zone=$3

gcloud compute instances describe ${instance} --zone  ${zone}    --project ${proj} --format=json > ${instance}.json
 
# ./metadata.sh vpc-0 project1 asia-south1-c