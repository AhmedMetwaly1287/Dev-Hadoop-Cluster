#!/bin/bash

source /shared/scripts/init-node.sh

echo "Starting DataNode..."
hdfs --daemon start datanode

echo "Starting NodeManager..."
yarn --daemon start nodemanager

echo ""
echo "========== STATUS REPORT: $HOSTNAME =========="
echo "--- DataNode ---"
hdfs --daemon status datanode

echo "--- NodeManager ---"
yarn --daemon status nodemanager


sleep infinity