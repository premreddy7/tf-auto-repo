#!/bin/bash

mkdir -p /opt/anypoint/runtimefabric
cat >> /opt/anypoint/runtimefabric/env <<EOF
RTF_NODE_ROLE=worker_node
RTF_INSTALL_ROLE=joiner
RTF_DOCKER_DEVICE_SIZE=250G
RTF_TOKEN="${cluster_token}"
RTF_INSTALLER_IP="${installer_ip}"
RTF_HTTP_PROXY='${http_proxy}'
RTF_NO_PROXY='${no_proxy}'
RTF_SERVICE_UID='${service_uid}'
RTF_SERVICE_GID='${service_gid}'
POD_NETWORK_CIDR='${pod_network_cidr_block}'
SERVICE_CIDR='${service_cidr_block}'
DISABLE_SELINUX=${disable_selinux}
BLOCK_AWS_EC2_METADATASVC=${block_aws_metadata_svc}
RTF_PRIVATE_INTERFACE=${private_interface}
EOF
