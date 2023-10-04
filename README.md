
# makeHiveQueryExecutor.sh

`makeHiveQueryExecutor.sh` is a comprehensive tool designed to simulate various Hive query execution scenarios using JDBC. The tool generates Java source code and subsequently compiles it into binary classes. The primary objective is to allow users to test various conditions that might arise when handles, such as ResultSet, Statement, and Connection, are not closed appropriately. The default query targets the `hivesampletable`, but the Java source code can be easily modified for other tables.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)

## Prerequisites

- Be sure you have a functional Spark or Hive cluster with access to hivesampletable.
- This tool is designed to run on any node within a Hive cluster including edge nodes

## Installation

1. Clone the GitHub repository to your desired location:
```bash
git clone [URL-of-your-GitHub-repo]
cd [repository-name]
```

2. Run the `makeHiveQueryExecutor.sh` script to generate the Java source and compile it:
```bash
. makeHiveQueryExecutor.sh
```

## Usage

Upon successful script execution, the Java program will be written to `HiveQueryExecutor.java` and subsequently compiled. 
A custom usage list is returned with classpath for your cluster build. 
Save the usage list if needed and cut/paste from the list to execute various commands. 
Below is an example of what the output will look like:

1. **Run the query once and close all handles (Default Behavior):**
```bash
java -cp ".:$HADOOP_CLASSPATH:/usr/hdp/5.0.11.8/hive/jdbc/hive-jdbc-3.1.2.5.0.11.8-standalone.jar" HiveQueryExecutor 1
```

2. **Run the query 3 times and close all handles:**
```bash
java -cp ".:$HADOOP_CLASSPATH:/usr/hdp/5.0.11.8/hive/jdbc/hive-jdbc-3.1.2.5.0.11.8-standalone.jar" HiveQueryExecutor 3
```

3. **Run the query 5 times without closing the ResultSet (`rs`) handle:**
```bash
java -cp ".:$HADOOP_CLASSPATH:/usr/hdp/5.0.11.8/hive/jdbc/hive-jdbc-3.1.2.5.0.11.8-standalone.jar" HiveQueryExecutor 5 "rs"
```

4. **Run the query 7 times without closing the Statement (`stmt`) handle:**
```bash
java -cp ".:$HADOOP_CLASSPATH:/usr/hdp/5.0.11.8/hive/jdbc/hive-jdbc-3.1.2.5.0.11.8-standalone.jar" HiveQueryExecutor 7 "stmt"
```

5. **Run the query 10 times without closing the Connection (`conn`) handle:**
```bash
java -cp ".:$HADOOP_CLASSPATH:/usr/hdp/5.0.11.8/hive/jdbc/hive-jdbc-3.1.2.5.0.11.8-standalone.jar" HiveQueryExecutor 10 "conn"
```

6. **Run the query 2 times without closing the ResultSet (`rs`) and Statement (`stmt`) handles:**
```bash
java -cp ".:$HADOOP_CLASSPATH:/usr/hdp/5.0.11.8/hive/jdbc/hive-jdbc-3.1.2.5.0.11.8-standalone.jar" HiveQueryExecutor 2 "rs,stmt"
```

7. **Run the query 4 times without closing any of the handles:**
```bash
java -cp ".:$HADOOP_CLASSPATH:/usr/hdp/5.0.11.8/hive/jdbc/hive-jdbc-3.1.2.5.0.11.8-standalone.jar" HiveQueryExecutor 4 "rs,stmt,conn"
```

## Features

- **Randomized Querying:** Each execution uses a randomized LIMIT clause for variability.
- **Handle Management:** Test scenarios with flexibility on handle closures to mimic potential resource leaks.
- **Logging:** Simplified logging provides clarity on execution status and errors.



