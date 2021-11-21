#!/bin/bash

#echo -n "Enter the new 'GroupName' for new Hadoop user : "
#read username
echo -n "Enter the 'UserName' for Hadoop: "
read UserName

echo -n 'Enter the directory you want to install Hadoop in : '
read hadoopdir


echo "...................Updating your System.................."

sudo apt update

JAVA_VERSION=`echo "$(java -version 2>&1)" | grep "java version" | awk '{ print substr($3, 4, length($3)-9); }'`

#checking for java 7, In this script we are using default jdk from ubuntu  
if [ $JAVA_VERSION -eq "8" ] ; then
	echo "Java 8 is installed in your system "

else 
	echo "-----------------Removing older version of Java and installing default JDK of Ubuntu--------------"
	sudo apt-get autoremove java-common
	sudo apt install openjdk-8-jdk -y
fi 

#Getting JAVA_HOME value and storing in java_home variable

java_home=`echo $JAVA_HOME`

#echo "-----------------Adding a dedicated HADOOP user---------------------------"

#sudo addgroup $hdGroup

#echo "------------------Enter the Details for new HADOOP user---------------------------"
#sudo adduser -ingroup $hdGroup $hdUserName

#echo "--------New $hdGroup  GROUP is created and $hdUserName USER is assaigned to Group------------------"

echo "------------------------Installing  Open SSH on Ubuntu------------------------------- "

sudo apt install openssh-server openssh-client -y


#echo "--------Please press Enter when asking for file to save RSA keys -------------------------------"

#sudo -u $hdUserName ssh-keygen -t rsa -P ""
#sudo -u $hdUserName cat /home/$hdUserName/.ssh/id_rsa.pub >> /home/$hdUserName/.ssh/authorized_keys
echo ".....enabling Passwordless SSH............"

sudo apt install openssh-server openssh-client -y
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
ssh localhost

#Download hadoop3.3.1 from apache
sudo wget https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz  

sudo chmod 777 hadoop-3.3.1.tar.gz

sudo tar xvfz hadoop-3.3.1.tar.gz
#sudo mkdir -p $hadoopdir/hadoop
sudo  mv hadoop-3.3.1 $hadoopdir


echo "...............................giving permission to configure......................."
sudo  chmod o+w .bashrc
sudo chmod 777 /$hadoopdir
sudo chmod o+w /$hadoopdir/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
sudo  chmod o+w /$hadoopdir/hadoop-3.3.1/etc/hadoop/core-site.xml
sudo chmod o+w /$hadoopdir/hadoop-3.3.1/etc/hadoop/mapred-site.xml
sudo chmod o+w /$hadoopdir/hadoop-3.3.1/etc/hadoop/hdfs-site.xml
sudo chmod o+w /$hadoopdir/hadoop-3.3.1/etc/hadoop/yarn-site.xml

echo "...............................updating Hadoop environment......................."
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64'>> $hadoopdir/hadoop-3.3.1/etc/hadoop/hadoop-env.sh	


echo "...............................updating bash environment......................."

echo 'export HADOOP_HOME=$hadoopdir/hadoop-3.3.1
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/nativ' >> .bashrc

source .bashrc
echo "...............................updating CORE's file......................."
#core-site.xml
echo '<configuration>
<property>
  <name>hadoop.tmp.dir</name>
  <value>/home/hdoop/tmpdata</value>
</property>
<property>
  <name>fs.default.name</name>
  <value>hdfs://127.0.0.1:9000</value>
</property>
</configuration>' >> $hadoopdir/hadoop-3.3.1/etc/hadoop/core-site.xml


#hdfs-site.xml
echo "...............................updating HDFS's file......................."
echo '<configuration>
<property>
  <name>dfs.data.dir</name>
  <value>/home/hdoop/dfsdata/namenode</value>
</property>
<property>
  <name>dfs.data.dir</name>
  <value>/home/hdoop/dfsdata/datanode</value>
</property>
<property>
  <name>dfs.replication</name>
  <value>1</value>
</property>
</configuration>' >> $hadoopdir/hadoop-3.3.1/etc/hadoop/hdfs-site.xml

echo "...............................updating MAPRED's file......................."
#mapred-site.xml
echo '<configuration> 
<property> 
  <name>mapreduce.framework.name</name> 
  <value>yarn</value> 
</property> 
</configuration>'>> $hadoopdir/hadoop-3.3.1/etc/hadoop/mapred-site.xml


echo "...............................updating Yarn's file......................."
#Yarn-site.xml
echo '<configuration>
<property>
  <name>yarn.nodemanager.aux-services</name>
  <value>mapreduce_shuffle</value>
</property>
<property>
  <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
  <value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>
<property>
  <name>yarn.resourcemanager.hostname</name>
  <value>127.0.0.1</value>
</property>
<property>
  <name>yarn.acl.enable</name>
  <value>0</value>
</property>
<property>
  <name>yarn.nodemanager.env-whitelist</name>   
  <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PERPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
</property>
</configuration>' >> $hadoopdir/hadoop-3.3.1/etc/hadoop/yarn-site.xml


#echo "--------------------HADOOP DIRECTORY------------------------- "
#sudo ls /hadoopdir/hadoop-3.2.1/


hdfs namenode -format

sudo ls /hadoopdir/hadoop-3.2.1/sbin

./start-dfs.sh

./start-yarn.sh

