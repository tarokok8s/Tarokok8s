#!/bin/bash
adminuser=bigred
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
export HADOOP_HOME=/opt/hadoop-3.3.6
export HADOOP_LOG_DIR=/tmp
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native/
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
# export HADOOP_USER_CLASSPATH_FIRST=true
[ -z $HADOOP_USER_NAME ] && [ $SHELL == '/bin/bash' ] && declare -r HADOOP_USER_NAME=$USER

# JobHistory log file path, 會自動產生目錄
export HADOOP_MAPRED_LOG_DIR="/tmp/jhslog"

export YARN_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export YARN_LOG_DIR=/tmp

# hadoop 3.2.1 及 3.1.3 這二個版本只要執行檔案傳送命令就會出現以下訊息
# hadoop fs -put -f /etc/passwd /tmp
# SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
export HADOOP_ROOT_LOGGER="WARN,console"

export PIG_HOME=/opt/pig-0.17.0
export PIG_HEAPSIZE=512
export HIVE_HOME=/opt/apache-hive-3.1.3-bin

export PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=/home/bigred/vmusdt/bin:$PATH
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PIG_HOME/bin:$HIVE_HOME/bin

export HBASE_HOME=/opt/hbase-2.4.17
export HBASE_CONF_DIR=/opt/hbase-2.4.17/conf
export ZOOKEEPER_HOME=/opt/apache-zookeeper-3.8.3-bin
export ZOO_LOG_DIR=/tmp/logs
export PATH=$PATH:$ZOOKEEPER_HOME/bin:$HBASE_HOME/bin

export SPARK_HOME=/opt/spark-3.3.4-bin-hadoop3
export SPARK_CONF_DIR=$SPARK_HOME/conf
export PYSPARK_PYTHON=/usr/bin/python3
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

if [ -d /opt/jupyter/miniconda3/bin ];then
   export ANACONDA_ROOT=/opt/jupyter/miniconda3
   export PATH=$ANACONDA_ROOT/bin:$PATH
   export PYSPARK_PYTHON=$ANACONDA_ROOT/bin/python
fi

if [ "$USER" != "" ]; then

   [ -f /home/$USER/dkc.env ] && source /home/$USER/dkc.env

   if [ ! -d metastore_db ]; then
      #hn=$(hostname)
      #if [ ${hn:0:3} == "adm" ] || [ ${hn:0:2} == "ds" ] || [ ${hn:0:8} == "zeppelin" ]; then
      schematool -initSchema -dbType derby &>/dev/null
      if [ "$?" == "0" ]; then
         echo "Embedded metastore(Derby) ok"
         echo "set hive.cli.print.current.db=true;" > .hiverc
         echo "set hive.metastore.warehouse.dir=/user/$USER/hive;" >> .hiverc
         echo "set hive.exec.scratchdir=/user/$USER/tmp;" >> .hiverc
      fi
   fi

   alias nano='nano -Ynone'
   alias dir='ls -alh'
   alias ssh='ssh -q'
fi

[ "$USER" == "bigred" ] && env | grep -E '^PATH|HADOOP_HOME|HADOOP_LOG_DIR|HADOOP_CONF_DIR|JAVA_HOME|SPARK_HOME|HBASE_HOME' | sudo tee /etc/environment &>/dev/null
