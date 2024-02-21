startAPM(){
#!/bin/sh

if [ $# -eq 1 ]; then
	cd ..
fi

echo ""
echo "##########################################################################"
echo " Note:It is recommended to start the product in nohup mode."
echo " Usage : nohup sh startApplicationsManager.sh & "
echo "##########################################################################"

cd working

export NMS_HOME=`pwd`

. ./setEnv.sh

. ./bin/unpack.sh

export CLASS_PATH=$NMS_HOME/../logs:$NMS_HOME/../:$NMS_CLASSES:$NMS_CLASSES/AdventNetAppManager.jar:$NMS_CLASSES/AdventNetOPExtn.jar:$NMS_CLASSES/jfreechart.jar:$NMS_CLASSES/jcommon.jar:$NMS_CLASSES/AdventNetNPrevalent.jar:./apache:./apache/tomcat:$NMS_CLASSES/ApiUtils.jar:./:$WEBSERVER_CLASSPATH:$DB_CLASSPATH:$LICENSE_PATH:$APPLN_MON_SERVER_CLASSPATH:$USER_LIB_PATH:$NMS_HOME/../lib/ext/classes12.zip:$NMS_CLASSES/json.jar:$NMS_CLASSES/jt400.jar:$NMS_CLASSES/dnsjava-2.0.6.jar:$NMS_CLASSES/commons-net-2.0.jar:$NMS_CLASSES/stax-api-1.0.1.jar:$NMS_CLASSES/stax-1.2.0.jar

JAVA_OPTS="-javaagent:apminsight/self-monitor/apminsight-javaagent.jar -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.util.logging.config.file=$TOMCAT_HOME/conf/logging.properties -Dcatalina.home=$TOMCAT_HOME -Dfile.encoding=UTF-8 -Dhttps.protocols=TLSv1.3,TLSv1.2,TLSv1.1,TLSv1 -Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true"
JAVA_MEM_OPTS="-Xms64m -Xmx1024m -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=256m"
JAVA_HEADLESS="-Djava.awt.headless=true"
JAVA_HEAPDUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEAPDUMP_PATH="-XX:HeapDumpPath=$NMS_HOME/heapdump/"

# Checking whether DISPLAY variable set the system or not.
#if [ "$DISPLAY" = "" ]; then
#	JAVA_HEADLESS="-Djava.awt.headless=true"
#fi

$JAVA_HOME/bin/java -cp "$CLASS_PATH" $JAVA_OPTS $JAVA_MEM_OPTS $JAVA_HEADLESS $JAVA_HEAPDUMP $HEAPDUMP_PATH com.adventnet.appmanager.server.startup.StartServer "$NMS_HOME"

export exit_code=$?
if [ "$exit_code" = 100 ]; then
	echo "Restarting the ApplicationsManager with 2 minutes delay.... "
	cd ..
	sleep 120
	startAPM
elif [ "$exit_code" = 110 ]; then
    echo "Restarting the ApplicationsManager with 2 minutes delay.... "
    ./bin/stopPGSQL.sh
    cd ..
    sleep 120
    startAPM
elif [ "$exit_code" = 200 ]; then
    cd ..
    echo "Going to Rename Logs folder"
    mv logs logs_$(date '+%d_%m_%Y_%H_%M_%S')
 	mkdir logs
 	echo "Restarting the ApplicationsManager with 2 minutes delay.... "
    sleep 120
    startAPM
elif [ "$exit_code" = 210 ]; then
    ./bin/stopPGSQL.sh
    cd ..
    echo "Going to Rename Logs folder"
    mv logs logs_$(date '+%d_%m_%Y_%H_%M_%S')
 	mkdir logs
 	echo "Restarting the ApplicationsManager with 2 minutes delay.... "
    sleep 120
    startAPM
	#Means exit_code other than 51 and not plugin build
elif [ ! -d "$NMS_HOME"/../../ancillary  -a  !"$exit_code" = 51 ]; then
    cd $NMS_HOME
    ./bin/stopPGSQL.sh 
fi
}
LCK_FILE="startup.lck"
if [ -f "$LCK_FILE" -a ! -w "$LCK_FILE" ]; then
    echo "User does not have proper permissions to start APM."
    echo "Refer: https://www.manageengine.com/products/applications_manager/help/starting-applications-manager.html"
    exit
fi

cd working
./jre/bin/java -cp ./classes:./classes/AdventNetAppManager.jar:./classes/commons-io-2.11.0.jar com.adventnet.appmanager.server.framework.CheckStartupScript
cd ..

firstArg=$1
if [ "$firstArg" = "sleep_start" ]; then
    sleep 120 
fi
export PROD_HOME=`pwd`

# Checking whether the user is root user or not, for APM Plugin build
ID=`id | awk '{print $1}' | cut -d "=" -f2 | cut -d "(" -f1`
if [ -d "$PROD_HOME"/../ancillary -a ${ID} -ne 0 ]
then
    echo "You must be a root user to start the AppManager server."
    echo "Please login as root user and start the server again."
    exit 1
elif [ -d "$PROD_HOME"/../ancillary ]
then
    echo "Starting APM plugin server.."
    startAPM
    exit 1
fi
if [ "$firstArg" = "-n" ]; then
    echo "Starting server without wrapper.."
    startAPM
    exit 1
fi
case "`pwd`" in
    *"working") cd ..
    ;;
esac
cd ./bin
wrapper_status=$(./apm_wrapper.sh status)
IS_WRAPPER_RUNNING=""
IS_WRAPPER_INSTALLED=""

case "$wrapper_status" in
    *"is running"*) IS_WRAPPER_RUNNING="true"
    ;;
esac
# echo "Wrapper status : "$wrapper_status
if [ "X$IS_WRAPPER_RUNNING" != "X" ]; then
    echo $wrapper_status
    echo "Wrapper instance of the server is already running or the previous instance was not shutdown properly."
    echo "If latter is the case, shutdown the server using shutdownscript with '-force' as an argument and then try restarting."
    exit
fi

SERVICE_NAME_TXT="linuxServiceName.txt"
if [ -f "$SERVICE_NAME_TXT" ]; then
    case "$wrapper_status" in
        *"not installed"*) IS_WRAPPER_INSTALLED="false"
        ;;
    esac
    if [ "X$IS_WRAPPER_INSTALLED" = "X" ]; then
        echo "Applications Manager is installed as service."
        firstArg="-d"
    fi
fi

LOGS_DIRECTORY=../logs
if [ ! -d "$LOGS_DIRECTORY" ]; then
    mkdir $LOGS_DIRECTORY
    echo "Created logs folder.."
fi

if [ "$firstArg" = "-d" ]; then
   echo "Startup logs will be found at : "`pwd`"/logs/wrapper.log"
   ./apm_wrapper.sh start
else
    echo "Starting server in wrapper console mode(Default).."
    ./apm_wrapper.sh console
fi
