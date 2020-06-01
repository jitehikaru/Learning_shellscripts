kafka常用命令
kafka分区迁移

export JAVA_HOME=/usr/local/jdk8 && export PATH=$PATH:$JAVA_HOME/bin &&  /usr/local/kafka/bin/kafka-reassign-partitions.sh --zookeeper node.zk:2181  --reassignment-json-file movePartitions.json_test   --execute
export JAVA_HOME=/usr/local/jdk8 && export PATH=$PATH:$JAVA_HOME/bin &&  /usr/local/kafka/bin/kafka-reassign-partitions.sh --zookeeper node.zk:2181  --reassignment-json-file movePartitions.json_test   --verify

kafka启动命令：
export JAVA_HOME=/usr/local/jdk8 && export PATH=$PATH:$JAVA_HOME/bin  && /usr/local/kafka/bin/kafka-server-start.sh -daemon  config/server.properties

kafka查看日志文件中的消息：

export JAVA_HOME=/usr/local/jdk8 &&  /usr/local/kafka/bin/kafka-run-class.sh kafka.tools.DumpLogSegments --print-data-log --files /data/kafka-logs-1/test-46/00000000003927853962.log  

kafka创建topic

export JAVA_HOME=/usr/local/jdk8 && /usr/local/kafka/bin/kafka-topics.sh --zookeeper   node.zk:2181  --create  --topic test  --replication-factor 2 --partitions 64

查看消费组以及消费组中topic消费情况的两种方法： 

1.存储在zk中的消费组
export JAVA_HOME=/usr/local/jdk8 &&  /usr/local/kafka/bin/kafka-consumer-groups.sh   --zookeeper node.zk:2181  --list 

/usr/local/kafka/bin/kafka-consumer-groups.sh   --zookeeper node.zk:2181  --describe    --group   wa-report

2.存储在__consumer_offsets中的消费组
export JAVA_HOME=/usr/local/jdk8 && /usr/local/kafka/bin/kafka-consumer-groups.sh --new-consumer --bootstrap-server  node.kafka:9092 --list
export JAVA_HOME=/usr/local/jdk8 && /usr/local/kafka/bin/kafka-consumer-groups.sh --new-consumer --bootstrap-server  node.kafka:9092 --describe --group test-group
export JAVA_HOME=/usr/local/jdk8 && /usr/local/kafka/bin/kafka-consumer-groups.sh --new-consumer --bootstrap-server  node.kafka:9092 --describe --group  test-group

在终端消费某个topic

1.以zk方式消费
/usr/local/kafka/bin/kafka-console-consumer.sh    --zookeeper node.zk:2181   --topic test
2.以bootstrap-server方式消费
/usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server node.kafka:9092 --from-beginning --topic my-kafka-topic


修改某个topic的数据日志保留时间（由默认值改为1天）

1.新版本的方式
/usr/local/kafka/bin/kafka-configs.sh --zookeeper  node.zk:2181 --entity-type topics --entity-name topic_name --alter --add-config log.retention.hours=24
2.旧版本的方式
/usr/local/kafka/bin/kafka-topics.sh --zookeeper node.zk:2181 -topic topicname --alter --config retention.ms=86400000


查看某个topic的offset

/usr/local/kafka/bin/kafka-run-class.sh kafka.tools.GetOffsetShell  --broker-list  node.kafka:9092 --topic  my-kafka-topic --time -1


查看kafka集群的某个topic中共有多少条消息

export JAVA_HOME=/usr/local/jdk8 && /usr/local/kafka/bin/kafka-run-class.sh kafka.tools.GetOffsetShell  --broker-list  node.kafka:9092  --topic  my-kafka-topic  --time -1|awk -F":" '{sum+=$3}END{print sum}'
2666620810


for topic in {test1,test2,test3,test4};do echo $topic ; export JAVA_HOME=/usr/local/jdk8 && /usr/local/kafka/bin/kafka-run-class.sh kafka.tools.GetOffsetShell  --broker-list  node.kafka:9092  --topic  $topic  --time -1|awk -F":" '{sum+=$3}END{print sum}';done


增加某个topic的分区数（只可增，不可减）

假设有一个名为test的topic，只有1个partition，现在需要增加分区数到6个：
/usr/local/kafka/bin/kafka-topics.sh --zookeeper zookeeper_node1:2181 --alter --topic test --partitions 6

kafka leader 

export JAVA_HOME=/usr/local/jdk8 &&   export JAVA_HOME=/usr/local/jdk8 && /usr/local/kafka/bin/kafka-preferred-replica-election.sh  --zookeeper   zookeeper_node1:2181     >> 2019-1023-preferred-replica-election.txt

kafka单独设置某个topic的参数

Property(属性)
Default(默认值)
Server Default Property(server.properties)
说明(解释)
cleanup.policy
delete
log.cleanup.policy
日志清理策略选择有：delete和compact主要针对过期数据的处理，或是日志文件达到限制的额度，会被  topic创建时的指定参数覆盖
delete.retention.ms
86400000 (24 hours)
log.cleaner.delete.retention.ms
对于压缩的日志保留的最长时间，也是客户端消费消息的最长时间，同log.retention.minutes的区别在于一个控制未压缩数据，一个控制压缩后的数据。会被topic创建时的指定参数覆盖
flush.messages
None
log.flush.interval.messages
log文件”sync”到磁盘之前累积的消息条数,因为磁盘IO操作是一个慢操作,但又是一个”数据可靠性"的必要手段,所以此参数的设置,需要在"数据可靠性"与"性能"之间做必要的权衡.如果此值过大,将会导致每次"fsync"的时间较长(IO阻塞),如果此值过小,将会导致"fsync"的次数较多,这也意味着整体的client请求有一定的延迟.物理server故障,将会导致没有fsync的消息丢失.
flush.ms
None
log.flush.interval.ms
仅仅通过interval来控制消息的磁盘写入时机,是不足的.此参数用于控制"fsync"的时间间隔,如果消息量始终没有达到阀值,但是离上一次磁盘同步的时间间隔达到阀值,也将触发.
index.interval.bytes
4096
log.index.interval.bytes
当执行一个fetch操作后，需要一定的空间来扫描最近的offset大小，设置越大，代表扫描速度越快，但是也更耗内存，一般情况下不需要搭理这个参数
max.message.bytes
1,000,000
max.message.bytes
表示消息的最大大小，单位是字节
min.cleanable.dirty.ratio
0.5
log.cleaner.min.cleanable.ratio
日志清理的频率控制，越大意味着更高效的清理，同时会存在一些空间上的浪费，会被topic创建时的指定参数覆盖
retention.bytes
None
log.retention.bytes
topic每个分区的最大文件大小，一个topic的大小限制  = 分区数*log.retention.bytes。-1没有大小限log.retention.bytes和log.retention.minutes任意一个达到要求，都会执行删除，会被topic创建时的指定参数覆盖
retention.ms
None
log.retention.minutes
数据存储的最大时间超过这个时间会根据log.cleanup.policy设置的策略处理数据，也就是消费端能够多久去消费数据log.retention.bytes和log.retention.minutes达到要求，都会执行删除，会被topic创建时的指定参数覆盖
segment.bytes
1 GB
log.segment.bytes
topic的分区是以一堆segment文件存储的，这个控制每个segment的大小，会被topic创建时的指定参数覆盖
segment.index.bytes
10 MB
log.index.size.max.bytes
对于segment日志的索引文件大小限制，会被topic创建时的指定参数覆盖
log.roll.hours
7 days
log.roll.hours
这个参数会在日志segment没有达到log.segment.bytes设置的大小，也会强制新建一个segment会被  topic创建时的指定参数覆盖
例如：
/usr/local/kafka/bin/kafka-configs.sh --zookeeper   node.zk:2181   --entity-type topics --alter --add-config retention.ms=1000 --entity-name MyTopic
export JAVA_HOME=/usr/local/jdk8 && /usr/local/kafka/bin/kafka-topics.sh --zookeeper node.zk:2181  --alter   --topic  MyTopic     --delete-config   retention.ms


https://www.cnblogs.com/yinchengzhe/p/5111635.html


Kafka常用命令之kafka-console-consumer.sh                                                                

 kafka-console-consumer.sh 脚本是一个简易的消费者控制台。该 shell 脚本的功能通过调用 kafka.tools 包下的  ConsoleConsumer 类，并将提供的命令行参数全部传给该类实现。

注意：Kafka 从 2.2 版本开始将 kafka-topic.sh 脚本中的 −−zookeeper 参数标注为 “过时”，推荐使用 −−bootstrap-server 参数。若读者依旧使用的是 2.1 及以下版本，请将下述的 --bootstrap-server 参数及其值手动替换为 --zookeeper zk1:2181,zk2:2181,zk:2181。一定要注意两者参数值所指向的集群地址是不同的。

消息消费bin/kafka-console-consumer.sh --bootstrap-server node1:9092,node2:9092,node3:9092 --topic topicName1 表示从 latest 位移位置开始消费该主题的所有分区消息，即仅消费正在写入的消息。
从开始位置消费bin/kafka-console-consumer.sh --bootstrap-server node1:9092,node2:9092,node3:9092 --from-beginning --topic topicName1 表示从指定主题中有效的起始位移位置开始消费所有分区的消息。
显示key消费bin/kafka-console-consumer.sh --bootstrap-server node1:9092,node2:9092,node3:9092 --property print.key=true --topic topicName1 消费出的消息结果将打印出消息体的 key 和 value。
 若还需要为你的消息添加其他属性，请参考下述列表。

参数

值类型

说明

有效值

--topic

string

被消费的topic


--whitelist

string

正则表达式，指定要包含以供使用的主题的白名单

--partition

integer

指定分区




除非指定’–offset’，否则从分区结束(latest)开始消费





--offset

string

执行消费的起始offset位置




默认值:latest

latest




earliest




<offset>

--consumer-property

string

将用户定义的属性以key=value的形式传递给使用者





--consumer.config

string

消费者配置属性文件




 请注意，[consumer-property]优先于此配置





--formatter

string

用于格式化kafka消息以供显示的类的名称




默认值:kafka.tools.DefaultMessageFormatter

kafka.tools.DefaultMessageFormatter




kafka.tools.LoggingMessageFormatter




kafka.tools.NoOpMessageFormatter




kafka.tools.ChecksumMessageFormatter




--property

string

初始化消息格式化程序的属性

print.timestamp=true|false

print.key=true|false

print.value=true|false

key.separator=<key.separator>

line.separator=<line.separator>

key.deserializer=<key.deserializer>

value.deserializer=<value.deserializer>

--from-beginning

从存在的最早消息开始，而不是从最新消息开始

--max-messages

integer

消费的最大数据量，若不指定，则持续消费下去

--timeout-ms

integer

在指定时间间隔内没有消息可用时退出

--skip-message-on-error

如果处理消息时出错，请跳过它而不是暂停

--bootstrap-server

string

必需

(除非使用旧版本的消费者)，要连接的服务器

--key-deserializer

string

--value-deserializer

string

--enable-systest-events

除记录消费的消息外，还记录消费者的生命周期

(用于系统测试)

--isolation-level

string

设置为read_committed以过滤掉未提交的事务性消息

设置为read_uncommitted以读取所有消息

默认值:read_uncommitted

--group

string

指定消费者所属组的ID

--blacklist

string

要从消费中排除的主题黑名单

--csv-reporter-enabled

如果设置，将启用csv metrics报告器

--delete-consumer-offsets

如果指定，则启动时删除zookeeper中的消费者信息

--metrics-dir

string

输出csv度量值

需与[csv-reporter-enable]配合使用

--zookeeper

string

必需

(仅当使用旧的使用者时)连接zookeeper的字符串。 

可以给出多个URL以允许故障转移
