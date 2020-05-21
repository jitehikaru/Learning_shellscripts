#!/bin/bash -

HOME_DIR=/home/enter.jin
EXEC_FILE_DIR=$HOME_DIR/txt_20
TopicListFile=$HOME_DIR/topics_to_add_replicas.list
ZookeeperList=sh-nh-b2-2-m13-xstorm-3-220:2181,sh-nh-b2-2-m12-xstorm-3-221:2181,sh-nh-b2-2-m13-xstorm-3-222:2181,sh-nh-b2-2-m12-xstorm-3-223:2181,sh-nh-b2-2-m12-xstorm-3-219:2181

export JAVA_HOME=/usr/local/jdk
export PATH=$PATH:$JAVA_HOME/bin
export KAFKA_HOME=/usr/local/kafka

result_log=$HOME_DIR/exec_movePartitions_json.log

if [ -f "${result_log}" ];then
    mv ${result_log}{,.`date "+%Y-%m-%d"`}
else
    echo "${result_log} is not exsitence"
fi

start_all_time=`date "+%Y-%m-%d %H:%M:%S"`
echo "${start_all_time}: Start to exec the shellscript" >> ${result_log}

for topic in `cat ${TopicListFile}`
do

  start_one_time=`date "+%Y-%m-%d %H:%M:%S"`
  echo "${start_one_time}: Start to exec ${topic}" >> ${result_log}

  exec_flie=${EXEC_FILE_DIR}/movePartitions.json_${topic}
  ${KAFKA_HOME}/bin/kafka-reassign-partitions.sh --zookeeper  ${ZookeeperList}  --reassignment-json-file  ${exec_flie}  --execute
  NumOfCompleted=0
  while [ ${NumOfCompleted} != 64 ]
  do
    NumOfCompleted=`${KAFKA_HOME}/bin/kafka-reassign-partitions.sh --zookeeper  ${ZookeeperList}  --reassignment-json-file  ${exec_flie}  --verify |grep completed|wc -l`
    echo "Reassignment of topic ${topic} is still in progress" >> ${result_log}
    sleep 5
  done
  echo "Reassignment of topic ${topic} completed successfully" >> ${result_log}

  end_one_time=`date "+%Y-%m-%d %H:%M:%S"`
  echo "${end_one_time}: End to exec ${topic}" >> ${result_log}

done

end_all_time=`date "+%Y-%m-%d %H:%M:%S"`
echo "${end_all_time}: End to exec the shellscript" >> ${result_log}
