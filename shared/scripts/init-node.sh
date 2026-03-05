#!/bin/bash

source /shared/env/hadoop.env

if [ ! -d "/opt/hadoop" ]; then
    echo "Extracting Hadoop..."
    tar -xzf /shared/hadoop-3.4.2.tar.gz -C /opt/
    mv /opt/hadoop-3.4.2 /opt/hadoop
fi

if [ ! -d "/opt/java" ]; then
    echo "Extracting Java..."
    tar -xzf /shared/microsoft-jdk-17.0.18-linux-x64.tar.gz -C /opt/
    mv /opt/jdk-17.0.18+8 /opt/java
fi


echo "Verifying Hadoop installation..."
/opt/hadoop/bin/hadoop version


