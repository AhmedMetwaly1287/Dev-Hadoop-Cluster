# **Development-based Hadoop Cluster**
- A project for the Hadoop Course provided by the **Information Technology Institute** (ITI) aiming to simulate a **development-grade** Hadoop Cluster consisting of **5 nodes** ensuring **high availability** for all services included with the ability to scale out in the future with ease.

---

## Table of Contents
- [Problem Statement](#problem-statement)
- [Requirements](#requirements)
    - [Functional Requirements](#functional-requirements)
    - [Non Functional Requirements](#non-functional-requirements)
- [High Level Architecture](#high-level-architecture)
- [Design Choices and Trade offs](#design-choices-and-trade-Offs)
- [Deployment](#deployment)
- [Challenges](#challenges)
- [Future Improvements](#future-improvements)

---

## Problem Statement
- We're tasked with setting up and configuring a Hadoop cluster consisting of 5 nodes meant for development purposes, high availability for all services included must be ensured, for HDFS, There must be **two NameNodes (active and standby)** with automatic failover to automatically transfer control from one NameNode to another to ensure minimal downtime of the cluster, However, for YARN, **two ResourceManagers (active and standby)** should also be available in case of the failure of one, another takes over following the same concept as NameNode to ensure job continuity, a replication factor of **1** is also set up in order to ensure **data availability** avoid data loss and in an effort to achieve data locality, making processing much faster, Finally, the goal is to simulate Production-grade cluster resilience and availability for our development Hadoop Cluster.

---

## Requirements
- This section is going to demonstrate the **functional** and **non-functional** requirements of the project.
### Functional Requirements
- PLACEHOLDER
### Non-Functional Requirements
- PLACEHOLDER

---

## High Level Architecture
- node01 — Master A

NameNode (Active)
ResourceManager (Active)
JournalNode
ZooKeeper
ZKFC

- node02 — Master B

NameNode (Standby)
ResourceManager (Standby)
JournalNode
ZooKeeper
ZKFC

- node03 — Worker + Quorum Tiebreaker

DataNode
NodeManager
JournalNode
ZooKeeper

- node04 — Pure Worker

DataNode
NodeManager

- node05 — Pure Worker

DataNode
NodeManager

- IMAGE PLACEHOLDER

---

## Design Choices and Trade offs
- In this section, we outline the key architectural decisions made and discuss the reasoning behind them. Each choice reflects a balance between reliability, performance, and resource constraints within our environment. We also highlight the trade-offs that were necessary — for example, opting for high availability mechanisms that increase complexity but ensure resilience, or setting replication factors that conserve storage while impacting redundancy.

---

## Deployment
- PLACEHOLDER, MIGHT BE REMOVED

---

## Challenges
- This section is going to discuss the challenges faced in the process of setting up and deploying services over the nodes and how they were overcame.

---

## Future Improvements
- PLACEHOLDER