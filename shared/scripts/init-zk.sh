#!/bin/bash

if [ ! -d "/opt/zookeeper" ]; then
    echo "Extracting ZooKeeper..."
    tar -xzf /shared/apache-zookeeper-3.8.6-bin.tar.gz -C /opt/
    mv /opt/apache-zookeeper-3.8.6-bin /opt/zookeeper
fi

