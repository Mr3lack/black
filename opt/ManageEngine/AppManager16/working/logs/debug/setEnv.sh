#!/bin/sh
#$Id$
#This file is to set the environmental variables used by the scripts located under the <NMS_HOME>/bin.
#Changes included in this file will gets reflected in all the shell files used under the <NMS_HOME>/bin.

NMS_HOME=`pwd`

JAVA_HOME=$NMS_HOME/jre

POSTGRESQL_JAR=postgresql-42.4.0.jar

AMSERVER_PROPFILE=../conf/AMServer.properties

#Looping through the AMServer.properties file and loading the properties to shell variables using the same key name from the file. But dots(.) in the key names are replaced with underscore(_) since shell variables cannot have dot(.) in their name 

 while IFS='=' read -r key value
  do
  	if ! [ -z "${key}" ];then
    	key=$(echo $key | tr '.' '_')
    	eval ${key}=\${value}
    fi
  done < "$AMSERVER_PROPFILE"

#Getting the edition type from AMServer.properties
EDITION_TYPE=${am_edition_type}


if [ "$EDITION_TYPE" = 'PlugIn' ];then
	POSTGRESQL_JAR=postgresql-42.4.0.jar; 
fi

#OSX Hack to JRE
if [ `uname -s` = "Darwin" ]; then
	echo "The JAVA_HOME environment variable for Mac OSX is bring set"
    export JAVA_HOME=$NMS_HOME/jre/Contents/Home
fi

if [ ! -x "$JAVA_HOME"/bin/java ]; then 
	echo "The JAVA_HOME environment variable is not defined correctly"
    export JAVA_HOME=$NMS_HOME/jre
fi

JAVA_COMPILER=NONE
export JAVA_COMPILER

# LICENSE_PATH variable is to locate AdventNetLicense.ali directory path.
LICENSE_PATH=$NMS_HOME:$AM_HOME

NMS_CLASSES=$NMS_HOME/classes

XML_CLASSPATH=$NMS_CLASSES/jaxp.jar:$NMS_CLASSES/xalan.jar

MYSQL_HOME=$NMS_HOME/mysql

PGSQL_HOME=$NMS_HOME/pgsql

DB_CLASSPATH=$NMS_CLASSES/$POSTGRESQL_JAR

WEBSERVER_HOME=$NMS_HOME/apache/tomcat

TOMCAT_HOME=$WEBSERVER_HOME

WEBSERVER_CLASSPATH=$TOMCAT_HOME/lib/servlet-api.jar:$TOMCAT_HOME/lib/jsp-api.jar:$TOMCAT_HOME/lib/el-api.jar:$TOMCAT_HOME/bin/bootstrap.jar:$NMS_CLASSES/jfreechart.jar:$NMS_CLASSES/jcommon.jar:$TOMCAT_HOME/bin/tomcat-juli.jar:$TOMCAT_HOME/bin/commons-logging-1.1.3.jar:$TOMCAT_HOME/lib/tomcat-api.jar:$TOMCAT_HOME/lib/jasper-el.jar:$TOMCAT_HOME/lib/jasper.jar

WEBSERVER_JARS=$WEBSERVER_CLASSPATH:$XML_CLASSPATH

CLI_CLIENT_CLASSPATH=$NMS_CLASSES/AdventNetCLIClient.jar:$NMS_CLASSES/AdventNetJta.jar

CLI_CLASSPATH=$NMS_CLASSES/AdventNetCLI.jar:$CLI_CLIENT_CLASSPATH

JMX_AGENT_CLASSPATH=$NMS_CLASSES/AdventNetSnmpAgent.jar:$NMS_CLASSES/xmojo.jar:$NMS_CLASSES/WebLogicClient.jar:$NMS_CLASSES/ClientFramework.jar:$NMS_CLASSES/JMXAdaptorFramework.jar:$NMS_CLASSES/AdventNetJmxAgent.jar:$NMS_CLASSES/AdventNetWebNmsAgent.jar:$NMS_CLASSES/AdventNetARUtils.jar:$NMS_CLASSES/AdventNetTL1Agent.jar:$NMS_CLASSES/WebSphereClient.jar:$NMS_CLASSES/AdventNetRuntimeUtilities.jar

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NMS_HOME/lib:$WEBSERVER_HOME/lib
export LD_LIBRARY_PATH

TRANSACTION_CLASSPATH=$NMS_CLASSES/jta.jar

MS_CLIENT_CLASSPATH=$NMS_CLASSES/ManagementClient.jar

MS_CLASSPATH=${NMS_CLASSES}/ManagementServer.jar:${MS_CLASSPATH}

JIMI_CLASSPATH=${NMS_CLASSES}/JimiProClasses.zip:${NMS_CLASSES}/jfreechart.jar:${NMS_CLASSES}/jcommon.jar

host=localhost

CODEBASE_LIST=\"file:///$NMS_HOME/classes/\ file:///$NMS_HOME/classes/AdventNetWebNMS.jar\ file:///$NMS_HOME/classes/AdventNetAppManager.jar\ file:///$NMS_HOME/classes/ManagementServer.jar\ file:///$NMS_HOME/classes/AdventNetTftp.jar\ file:///$NMS_HOME/classes/AdventNetCLI.jar\ file:///$NMS_HOME/classes/xmojo.jar\ file:///$NMS_HOME/classes/AdventNetSnmp.jar\ file:///$NMS_HOME/classes/SNMPDebugger.jar\ file:///$NMS_HOME/classes/AdventNetJmxAgent.jar\ file:///$NMS_HOME/classes/AdventNetARUtils.jar\ file:///$NMS_HOME/classes/AdventNetTL1Agent.jar\ file:///$NMS_HOME/classes/AdventNetSAS.jar\ file:///$NMS_HOME/classes/jta.jar\ file:///$NMS_HOME/appln_mon/classes/ApplnMonitorServer.jar\"

FTP_CLASSPATH=$NMS_CLASSES/ftp.jar

USER_LIB_PATH=

APPLN_MON_SERVER_CLASSPATH=$NMS_HOME/appln_mon/classes/ApplnMonitorServer.jar:$NMS_HOME/classes/CommonUtils.jar:$NMS_HOME/appln_mon/classes/ApplnMonitorCommon.jar:$NMS_HOME/appln_mon/classes

export PATH=$NMS_HOME/lib:$PATH

