#!/bin/bash

source /shared/scripts/init-node.sh

case $HOSTNAME in
  node01)
    source /shared/scripts/init-zk.sh
    zkServer.sh start /shared/cfg/zoo.cfg
    hdfs --daemon start journalnode

    if [ ! -d "/mnt/node-data/nn/current" ]; then
        echo "Fresh node01 - formatting NameNode..."
        hdfs namenode -format -force
        echo "Formatting ZooKeeper for ZKFC..."
        hdfs zkfc -formatZK -force
    fi

    hdfs --daemon start namenode
    hdfs --daemon start zkfc
    yarn --daemon start resourcemanager
    
    sleep 30
    ;;

  node02)
    source /shared/scripts/init-zk.sh
    zkServer.sh start /shared/cfg/zoo.cfg
    hdfs --daemon start journalnode

    if [ ! -d "/mnt/node-data/nn/current" ]; then
        echo "Fresh node02 - bootstrapping Standby NameNode..."
        hdfs namenode -bootstrapStandby -force
    fi

    hdfs --daemon start namenode
    hdfs --daemon start zkfc
    yarn --daemon start resourcemanager
    ;;

  node03)
    source /shared/scripts/init-zk.sh
    zkServer.sh start /shared/cfg/zoo.cfg
    hdfs --daemon start journalnode
    hdfs --daemon start datanode
    yarn --daemon start nodemanager
    ;;

  node04|node05)
    hdfs --daemon start datanode
    yarn --daemon start nodemanager
    ;;
esac

sleep infinity