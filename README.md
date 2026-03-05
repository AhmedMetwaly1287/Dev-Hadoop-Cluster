![Hadoop Logo](./documentation/hadoop.svg)

# **Development-based Hadoop Cluster**

- A project for the Hadoop Course provided by the **Information Technology Institute** (ITI) aiming to simulate a **development-grade** Hadoop Cluster consisting of **5 nodes** ensuring **high availability** for all services included with the ability to scale out in the future with ease.

---

## Table of Contents

- [Problem Statement](#problem-statement)
- [Requirements](#requirements)
  - [Functional Requirements](#functional-requirements)
  - [Non Functional Requirements](#non-functional-requirements)
- [High Level Architecture](#high-level-architecture)
- [Design Choices and Trade offs](#design-choices-and-trade-offs)
- [Deployment](#deployment)
- [Challenges and Issues Faced](#challenges-and-issues-faced)
- [Future Improvements](#future-improvements)

---

## Problem Statement

- We're tasked with setting up and configuring a Hadoop cluster consisting of 5 nodes meant for development purposes, high availability for all services included must be ensured, for HDFS, There must be **two NameNodes (active and standby)** with automatic failover to automatically transfer control from one NameNode to another to ensure minimal downtime of the cluster, However, for YARN, **two ResourceManagers (active and standby)** should also be available in case of the failure of one, another takes over following the same concept as NameNode to ensure job continuity, a replication factor of **1** is also set up in order to ensure **data availability** avoid data loss and in an effort to achieve data locality, making processing much faster, Finally, the goal is to simulate Production-grade cluster resilience and availability for our development Hadoop Cluster.

---

## Requirements

- This section is going to demonstrate the **functional** and **non-functional** requirements of the project.

### Functional Requirements  

**1.** This cluster should be able to run **Hadoop on all Nodes**, with each Node running **specific services** (refer to the **Design Choices section** for more).  

**2.** This cluster should implement **HDFS High Availability (HA)** by running **two NameNodes (Active and Standby states)** and a **quorum of JournalNodes**, as well as enabling **ZooKeeper** and **ZooKeeper Automatic Failover Controller (ZKFC)** to make the failover process **entirely automatic**.  

**3.** This cluster should implement **YARN High Availability (HA)** by running **two ResourceManagers (Active and Standby states)** and a **quorum of ZooKeeper nodes** for **automatic failover**.  

**4.** This cluster should be able to handle **all HDFS processes and requests** normally.  

**5.** All files stored on this cluster are subject to a **replication factor of 1**.  

**6.** This cluster should be able to run **all MapReduce jobs** submitted to process data stored on **HDFS**.  

**7.** This cluster exposes a **web interface for all services** to allow for **monitoring**.  


### Non-Functional Requirements  

**1.** The system shall maintain **cluster availability** in case of **single-node failure** affecting **NameNodes and ResourceManagers**, ensuring that **no service is a single point of failure**.  

**2.** The system shall ensure **metadata consistency** between **Active and Standby NameNodes** using **Quorum Journal Manager (QJM)**.  

**3.** The cluster shall **recover automatically from service failure** without requiring a **full cluster restart**.  

**4.** The cluster deployment shall be **reproducible using Docker Compose** on any compatible **Linux machine**.  

**5.** Cluster configuration files shall be **organized and documented** to allow **easy modification and troubleshooting**.  

**6.** The architecture shall allow adding **additional DataNodes** without **major architectural changes**.  

---

## High Level Architecture

![High Level Architecture](./documentation/HadoopDevHLA.drawio.png)

---

## Design Choices and Trade offs

- In this section, we outline the key architectural decisions made and discuss the reasoning behind them. Each choice reflects a balance between **reliability**, **performance**, and **resource constraints** within our environment. We also highlight the trade-offs that were necessary — for example, opting for **high availability mechanisms** that increase complexity but ensure resilience, or setting replication factors that conserve storage while impacting redundancy.

## Design Choices and Trade-offs

- In this section, we outline the key architectural decisions made and discuss the reasoning behind them. Each choice reflects a balance between **reliability**, **performance**, and **resource constraints** within our environment. We also highlight the trade-offs that were necessary — for example, opting for **high availability mechanisms** that increase complexity but ensure resilience, or setting replication factors that conserve storage while impacting redundancy.

### Cluster Architecture
- The cluster consists of **5 nodes**, we have opted for a **2 master - 3 worker architecture**, where each master is also running a **JournalNode** in addition to a **ZooKeeper node**. One of the workers was also chosen to run the last **JournalNode** and **ZooKeeper node** in addition to the **DataNode** and **NodeManager** it would normally be running.

### High Availability
- This architecture was chosen to conform with **Hadoop and YARN HA**. If one of the masters crashed, the cluster is expected to behave normally with **zero downtime** due to automatic failover controlled by the **ZooKeeper Failover Controller (ZKFC)**, which continuously monitors the **NameNode's health** and holds a lock on the **Active NameNode**. Upon failure, this lock is released and switched over to the **Standby NameNode**, as well as the majority of the **JournalNode** and **ZooKeeper quorum** nodes continuing to run, ensuring recovery of the failing JournalNode by **synchronizing edit logs** after recovery.

- In the case of the failure of **both masters**, the cluster halts due to the unavailability of **NameNodes** and **ResourceManagers** to elect — however it is worth noting that the **JournalNode and ZooKeeper quorum remain intact** since **node03** still holds the third node of each quorum.

### Quorum Size
- The reason why the cluster is running **3 JournalNodes** and **3 ZooKeeper nodes** is because the system can only afford **(n-1)/2** failures where **n** is the number of nodes. Opting for any less would cause **total failure** in the case of a single node failing, but picking **3** means our cluster can afford **1 failure**, making our system more durable.

### Replication Factor
- We have also opted for a **replication factor of 1**, one of the major trade-offs in the cluster where we **preserve storage** at the cost of risking losing access to data in the case of **DataNode failure**.

---

## Deployment

- To be able to deploy and start up the cluster, these steps must be followed:

1. **Clone the repostiory to your local machine:**

    ```bash
    git clone https://github.com/AhmedMetwaly1287/Dev-Hadoop-Cluster.git
    ```

2. **Download and install the required pre-requistes:**

- Please refer to the table below for the list of necessary tools, their respective versions, and official download links.

| Component   | Version | Link |
|-------------|---------|------|
| Java        | 17.10.18      | [Download Java](https://learn.microsoft.com/en-us/java/openjdk/download) |
| Hadoop      | 3.4.2   | [Download Hadoop](https://hadoop.apache.org/release/3.4.2.html) |
| ZooKeeper   | 3.8.6   | [Download ZooKeeper](https://zookeeper.apache.org/releases.html#download) |

**IMPORTANT NOTE:** Following the download of all 3 tarballs, it's important to put them under the **/shared** directory to allow the automatic start-up procedure to function as intended, otherwise, manual intervention might be needed.

3. **Move to dev-hadoop-cluster directory and run compose:**

    ```bash
    docker compose up
    ```

**IMPORTANT NOTE:** To validate that all services running on each node have started up correctly, you may navigate to the logs inside of each node container.

### Services' User Interface

- Below is a list of all available UIs that can be used to monitor and observe the health of services running on nodes, access logs and more.

| Component                | URL |
|--------------------------|-----|
| HDFS NameNode (master1) | [http://localhost:9871](http://localhost:9871) |
| HDFS NameNode (master2) | [http://localhost:9872](http://localhost:9872) |
| YARN ResourceManager (master1) | [http://localhost:8081](http://localhost:8081) |
| YARN ResourceManager (master2) | [http://localhost:8082](http://localhost:8082) |
| JournalNode 1 | [http://localhost:8481](http://localhost:8481) |
| JournalNode 2 | [http://localhost:8482](http://localhost:8482) |
| JournalNode 3 | [http://localhost:8483](http://localhost:8483) |

**IMPORTANT NOTE:** Bear in mind that only the UI of the **Active ResourceManager** may be displayed, accessing the **Standby ResouceManager** will only redirect you to the active one.

---

## Challenges and Issues Faced
- This section is going to discuss the challenges faced in the process of setting up and deploying services over the nodes and how they were overcame.


1. **NodeManager failing shortly after startup causing MapReduce jobs to freeze.**
    - During an attempt to test **MapReduce** functionality on the cluster, the job often got stuck without running the **Map** and **Reduce** tasks. During the debugging phase, it turned out that **NodeManager** showed that it was initially starting up but when attempting to check its status it didn't show up as running. Checking the logs, this error was the cause:

    ```bash
    java.lang.IllegalArgumentException: Cannot support recovery with an ephemeral server port. Check the setting of yarn.nodemanager.address
    ```
    
    After investigating further, this turned out to be a **configuration issue** — when **`yarn.nodemanager.recovery.enabled`** is set to `true`, the NodeManager requires a **fixed port** to be explicitly defined via **`yarn.nodemanager.address`**. Without it, the NodeManager picks a **random ephemeral port** on each startup which is incompatible with recovery. The fix was to either explicitly set the port or **disable NodeManager recovery** entirely, which was the chosen approach given the **dev environment** context.


2. **JournalNode performance issues and stale data conflicts.**
    - Experimenting with the cluster required halting and rebuilding it from scratch using **`docker-compose up`** and **`docker-compose down`** frequently. In the **docker-compose file**, each node mounts its data in a separate directory under the **`/mnt`** directory. This data was **retained even when rebuilding the cluster**, causing a conflict between the **old edit logs** written by the previous run and the services attempting to write new, up-to-date data in those directories. These conflicts caused **JournalNodes** to fail to load and execute successfully. It is important to note that after a while, **this issue escalated to all nodes refusing to start up**.


3. **Issues with automating node startup.**
    - Building the **automated startup script** to initialize, set up, and start services on each node was an **iterative process**. The first issue faced was that the **installation of Hadoop and Java** was lengthy and launched on every container start. To fix this, a **validation check** was added on startup to verify if Hadoop and Java were previously configured on the node. Afterwards, automating the **service startup sequence** proved difficult — services had to be **timed correctly** to avoid failures, particularly around **formatting the NameNode** and **ZKFC** on their respective nodes. To ensure formatting was only done once, another **validation step** was added to check if the **NameNode had been previously formatted** on this node by checking for the existence of the **`fsimage`** file.


4. **Consolidation of environment variables and sharing them among nodes.**
    - One of the most notable challenges was the **consolidation and sharing of environment variables** among all nodes, to prevent the time-consuming process of **manually exporting variables** on each node individually. A **`hadoop.env`** file was created to consolidate all environment variables in one place, and the **`docker-compose`** file was updated to attach this file to each node via the **`env_file`** directive, automatically injecting the variables into each container on startup.


5. **Windows carriage return character causing containers to fail on startup (`\r` issue).**
    - This was an issue caused by the **Windows operating system** appending a **carriage return character (`\r`)** to the end of each line in configuration and script files. This caused a **formatting incompatibility between Windows and Linux**, resulting in the cluster immediately failing on startup due to **configuration parsing errors**. The fix was to run **`sed -i 's/\r//'`** on all affected **`.sh`**, **`.xml`**, and **`.env`** files to strip the carriage return characters, and to prevent the issue from recurring after future commits.

---

## Future Improvements

- Possibly scale up by adding more nodes.
- Installing more services across nodes to add more processing and storage capabilites.
