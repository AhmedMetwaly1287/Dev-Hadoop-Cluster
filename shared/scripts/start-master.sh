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
    case $HOSTNAME in
        node01) echo "1" > /mnt/node-data/zk/myid ;;
        node02) echo "2" > /mnt/node-data/zk/myid ;;
    esac
fi

echo "Starting ZooKeeper..."
/opt/zookeeper/bin/zkServer.sh start /shared/cfg/zoo.cfg

echo "Starting JournalNode..."
hdfs --daemon start journalnode

case $HOSTNAME in
  node01)
    if [ ! -f "/mnt/node-data/nn/current/fsimage_0000000000000000000" ]; then
        echo "Fresh node01 - formatting NameNode..."
        hdfs namenode -format -force
        echo "Formatting ZooKeeper for ZKFC..."
        sleep 20
        hdfs zkfc -formatZK -force
    fi

    echo "Starting NameNode..."
    hdfs --daemon start namenode
    echo "Starting ZKFC..."
    hdfs --daemon start zkfc
    echo "Starting ResourceManager..."
    yarn --daemon start resourcemanager
    ;;

  node02)
    if [ ! -f "/mnt/node-data/nn/current/fsimage_0000000000000000000" ]; then
        echo "Fresh node02 - waiting for node01 NameNode..."
        sleep 30
        echo "Bootstrapping Standby NameNode..."
        hdfs namenode -bootstrapStandby -force
    fi

    echo "Starting NameNode..."
    hdfs --daemon start namenode
    echo "Starting ZKFC..."
    hdfs --daemon start zkfc
    echo "Starting ResourceManager..."
    yarn --daemon start resourcemanager
    ;;
esac

echo ""
echo "========== STATUS REPORT: $HOSTNAME =========="
echo "--- ZooKeeper ---"
/opt/zookeeper/bin/zkServer.sh status /shared/cfg/zoo.cfg

echo "--- JournalNode ---"
hdfs --daemon status journalnode

echo "--- NameNode ---"
hdfs --daemon status namenode

echo "--- ZKFC ---"
hdfs --daemon status zkfc

echo "--- ResourceManager ---"
yarn --daemon status resourcemanager

sleep infinity