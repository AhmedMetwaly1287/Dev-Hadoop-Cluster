#!/bin/bash

source /shared/scripts/init-node.sh

# Initialize ZooKeeper
if [ ! -d "/opt/zookeeper" ]; then
    tar -xzf /shared/apache-zookeeper-3.8.6-bin.tar.gz -C /opt/
    mv /opt/apache-zookeeper-3.8.6-bin /opt/zookeeper
fi

# Ensure myid exists
if [ ! -f "/mnt/node-data/zk/myid" ]; then
    mkdir -p /mnt/node-data/zk
    echo "3" > /mnt/node-data/zk/myid
fi

echo "Starting ZooKeeper..."
/opt/zookeeper/bin/zkServer.sh start /shared/cfg/zoo.cfg

echo "Starting JournalNode..."
hdfs --daemon start journalnode

echo "Starting DataNode..."
hdfs --daemon start datanode

echo "Starting NodeManager..."
yarn --daemon start nodemanager

echo ""
echo "========== STATUS REPORT: $HOSTNAME =========="
echo "--- ZooKeeper ---"
/opt/zookeeper/bin/zkServer.sh status /shared/cfg/zoo.cfg

echo "--- JournalNode ---"
hdfs --daemon status journalnode

echo "--- DataNode ---"
hdfs --daemon status datanode

echo "--- NodeManager ---"
yarn --daemon status nodemanager

sleep infinity