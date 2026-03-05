# Testing and Validation

- This section is going to demonstrate the testing of the cluster's **High Availability** features, **HDFS** and **YARN** failover scenarios, as well as the **MapReduce** functionality.

## HDFS High Availability Testing

### Scenario 1: Active NameNode Failure
- This scenario tests the **automatic failover** of the **Active NameNode** to the **Standby NameNode** upon failure.

1. Verify the current state of both NameNodes:
```bash
    hdfs haadmin -getServiceState nn1
    hdfs haadmin -getServiceState nn2
```
2. Stop the **Active NameNode** on **node01**:
```bash
    hdfs --daemon stop namenode
```
3. Verify that **nn2** has been automatically promoted to **Active**:
```bash
    hdfs haadmin -getServiceState nn2
```
4. Verify that the cluster is still serving requests:
```bash
    hdfs dfs -ls /
```

**Expected Outcome:** **nn2** is automatically promoted to **Active** state with **zero downtime**, the cluster continues to serve requests normally, and **ZKFC** handles the failover entirely automatically.

---

### Scenario 2: JournalNode Quorum Failure
- This scenario tests the **write operation failure** when the **JournalNode quorum** is lost.

1. Stop **JournalNodes** on **node02** and **node03**, leaving only one JournalNode running:
```bash
    # On node02
    hdfs --daemon stop journalnode

    # On node03
    hdfs --daemon stop journalnode
```
2. Attempt a **write operation** on HDFS:
```bash
    hdfs dfs -mkdir /test
```
3. Restore the **JournalNodes** on both nodes:
```bash
    hdfs --daemon start journalnode
```

**Expected Outcome:** The **write operation fails** because the **Active NameNode** cannot commit edit logs to the **JournalNode quorum** with only **1 out of 3** JournalNodes running, which is **below the majority threshold**. Read operations however continue to function normally. Upon restoring the JournalNodes, the cluster **resumes normal write operations** after the JournalNodes **synchronize their edit logs**.

---

## YARN High Availability Testing

### Scenario 3: Active ResourceManager Failure
- This scenario tests the **automatic failover** of the **Active ResourceManager** to the **Standby ResourceManager** upon failure.

1. Verify the current state of both ResourceManagers:
```bash
    yarn rmadmin -getServiceState rm1
    yarn rmadmin -getServiceState rm2
```
2. Stop the **Active ResourceManager** on **node01**:
```bash
    yarn --daemon stop resourcemanager
```
3. Verify that **rm2** has been automatically promoted to **Active**:
```bash
    yarn rmadmin -getServiceState rm2
```
4. Verify that the cluster is still able to accept jobs:
```bash
    yarn node -list
```

**Expected Outcome:** **rm2** is automatically promoted to **Active** state, the cluster continues to accept and process jobs normally, and **ZooKeeper** handles the failover entirely automatically.

---

### Scenario 4: Both Masters Failure
- This scenario tests the **expected behavior** of the cluster upon the failure of **both master nodes**.

1. Stop both **master nodes**:
```bash
    # On node01
    hdfs --daemon stop namenode
    yarn --daemon stop resourcemanager

    # On node02
    hdfs --daemon stop namenode
    yarn --daemon stop resourcemanager
```
2. Attempt a **read operation** on HDFS:
```bash
    hdfs dfs -ls /
```

**Expected Outcome:** The cluster **halts entirely** due to the unavailability of both **NameNodes** and **ResourceManagers**. It is worth noting that the **JournalNode** and **ZooKeeper quorum remain intact** since **node03** still holds the third node of each quorum, however this is of no use without any **NameNodes** or **ResourceManagers** to elect.

---

## MapReduce Testing

- This section demonstrates the **end-to-end** functionality of the cluster by ingesting data into **HDFS** and running a **WordCount MapReduce** job on it.

1. Create the input directory on **HDFS**:
```bash
    hdfs dfs -mkdir -p /input
```
2. Ingest the test data from the **shared staging area** into **HDFS**:
```bash
    hdfs dfs -put /shared/data/wordcount_test.txt /input
```
3. Verify the file is available on **HDFS**:
```bash
    hdfs dfs -ls /input
```
4. Submit the **WordCount MapReduce** job:
```bash
    hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.2.jar wordcount /input /output
```
5. Verify the job output:
```bash
    hdfs dfs -cat /output/part-r-00000
```

**Expected Outcome:** The **MapReduce** job runs successfully, processing the input data across the **DataNodes** and producing a **word frequency count** in the output directory on **HDFS**.