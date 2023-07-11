#!/bin/ksh

#-----Declare variable for script

host=$(hostname)
os=$(uname)

if [[ "$os" == 'Linux' ]]; then
	grep='grep'
	awk='awk'
	java_check="version"
else
	grep='ggrep'
	awk='nawk'
	java_check="version"
fi

#-----Start script

echo
echo "MAKE SURE SERVER HAS KSH (KORNSHELL)*"
echo "Set variable for the process..."
echo "===============>>"
if [[ "$os" == 'Linux' ]]; then
	read -p " <> USERNAME : " user	
	read -p " <> PASSWORD : " pass
else
	read user?" <> USERNAME : "
	read pass?" <> PASSWORD : "
fi
cnn_str="mysql -u $user -p"$pass

export PATH=$ORACLE_HOME/bin:$PATH
echo "<<==============="

#-----Get Date now

time=$(date +'%d_%m_%Y')

#-----Get pwd script

SCRIPT=$(readlink -f "$0")
pwd=$(dirname "$SCRIPT")

#-----Check connection

if
	echo "exit;" | $cnn_str 2>&1 | grep -q "MySQL"
then
	echo Connect Database SUCCESS
else
	echo Connect Database FAIL
fi

#-----Get db_name (all)

dbnames=$(
	$cnn_str -se "SELECT schema_name from INFORMATION_SCHEMA.SCHEMATA  WHERE schema_name NOT IN('information_schema', 'mysql', 'performance_schema');"
)

#-----Get database home(data directory)

dbhome=$(
	$cnn_str -se "SELECT CONCAT(@@datadir);"
)

#-----Get alert log path

spwd=$(
	$cnn_str -se "SELECT CONCAT(@@datadir);"
)

Head() {
    echo "===============>>"
    if [[ "$os" == 'Linux' ]]; then
	read -p " <> DATABASE_NAME : " dbname
    else
	read dbname?" <> DATABASE_NAME : "
    fi
    cnn_str_db="mysql -u $user -p"$pass $dbname
    echo "<<==============="
    #-----Create folder

    mkdir -p $pwd/${dbname}
    cd $pwd/${dbname}

	echo
	echo ">>--------------------------- *** ---------------------------<<"
	echo "<<========================<<  MPS  >>========================>>"
	echo ">>--------------------------- *** ---------------------------<<"
	echo
	echo " <> OS Machine :" $os
	echo " <> Date Time  :" $time
	echo " <> Script     :" $pwd
    echo " <> List DB    :" $dbnames
	echo " <> DB Name    :" $dbname
	echo " <> DB Home    :" $dbhome
	echo " <> Alert Log  :" $spwd
	echo " <> OSWbb Log  :" $pwd/oswbb_log_MPS_$host
	echo
	echo "|<<=======================<<  ***  >>=======================>>|"
	echo "|                                                             |"
	echo "|                    ---------------------                    |"
	echo "|   <<===>>       << HEALTH-CHECK-DATABASE >>       <<===>>   |"
	echo "|                    ---------------------                    |"
	echo "|                                                             |"
	echo "| ==>> 1. Get Database Information.                           |"
	echo "|                                                             |"
	echo "| ==>> 2. Run OSWatcher.                                      |"
	echo "|                                                             |"
	echo "| ==>> 3. Cancel Script.                                      |"
	echo "|                                                             |"
	echo "|                                                             |"
	echo "|                                         Ver_1.2.0_VictorMPS |"
	echo "|<<========================<< *** >>========================>>|"
	echo
	if [[ "$os" == 'Linux' ]]; then
		read -p "Option: " option
	else
		read option?"Option: "
	fi
}

Body() {
	#==#==Option Failed.

if [[ -z $option || $option < 1 || $option > 3 ]]; then
	echo
	echo "=> #Error! Choose again."

#==#==Option 1.(Run collect log)

elif [ $option == 1 ]; then
	echo
	echo "Processing..."
	echo

#-----Alert_log

cp $spwd/alert_$ORACLE_SID.log .
echo
echo "************************"
echo "* Copy Alert_log done. *"
echo "************************"
echo

#-----HealthCheck

sqlplus / as sysdba <<EOF
@$pwd/HealthCheck.sql
EOF
echo
echo "*************************"
echo "* Get HealthCheck done. *"
echo "*************************"
echo

#-----database_information

sqlplus / as sysdba <<EOF
@$pwd/database_information.sql
EOF
echo
echo "**********************************"
echo "* Get Database Information done. *"
echo "**********************************"
echo

#-----OS_Command

file_name='database_information.html'
unamestr=$(uname)
if [[ "$unamestr" == 'AIX' ]]; then
	disk_command='df -g'
else
	disk_command='df -h'
fi

#-----Disk_Usage

echo "<p>+ DISK_USAGE</p>" >>$file_name
$disk_command -P | $grep -v ^none | (
read header
echo "$header"
sort -rn -k 5 ) | $awk 'BEGIN{print("<table WIDTH='90%' BORDER='1'><tr><th>'FILESYSTEM'</th><th>'SIZE'</th><th>'USED'</th><th>'AVAIL'</th><th>'USE%'</th><th>'MOUNTED_ON'</th></tr>")}
{
	if ($2!="0K" && $2!="Size") {
		print("<tr><td>",$1,"</td><td>",$2,"</td><td>",$3,"</td><td>",$4,"</td><td>",$5,"</td><td>",$6,$7,"</td></tr>")
	}
}
END{
	print("</table><p><p>")
}' >>$file_name

#-----Check_Listener

echo "<p>+ CHECK_LISTENER</p>" >>$file_name
lsnrctl stat | awk 'BEGIN{
print("<p><table WIDTH='90%' BORDER='1'><tr><th>'LISTENER_STATUS'</th></tr><tr><td>")}
{
	if ($0!=NULL) {
		print($0,"<br>")
	}
}
	END{
		print("</tr></td></table><p><p>")
	}' >>$file_name

#-----Check_Patches

echo "<p>+ CHECK_PATCHES</p>" >>$file_name
$ORACLE_HOME/OPatch/opatch lsinventory | $grep -B 2 "Patch description" | grep -v "Unique" | $awk -v hs=$host -v oraclehome=$ORACLE_HOME 'BEGIN{print("<p><table WIDTH='90%' BORDER='1'><tr><th>SERVER</th><th>ORACLE_HOME</th><th>PATCH INFORMATION</th></tr><tr><td>",hs,"</td><td>",oraclehome,"</td><td>")}
{
	if ($0!=NULL) {
		print($0,"<br>")
	}
}
END{
	print("</tr></td></table><p><p>")
}' >>$file_name

#-----Backup_Policy

echo "<p>+ BACKUP_POLICY</p>" >>$file_name
echo "<table WIDTH='90%' BORDER='1'><tr><th>RMAN_RETENTION</th></tr><tr><td>" >>$file_name
rman target / <<EOF | grep CONFIGURE >>$file_name
show retention policy;
EOF
echo "</tr></td><tr><td>NULL</td></tr></table>" >>$file_name

#-----No Grid Option

if [ "$grid" == "N/A" ]; then
	echo "<p>+ RESOURCE_CRS</p>" >>$file_name
	echo "<table WIDTH='90%' BORDER='1'>" >>$file_name
	echo "<tr><th>NAME</th><th>TARGET</th><th>STATE</th><th>TARGET_SERVER</th><th>STATE_DETAILS</th></tr>" >>$file_name
	echo "<tr><td>NULL</td><td>NULL</td><td>NULL</td><td>NULL</td><td>NULL</td></tr></table>" >>$file_name
	echo "<p>+ CHECK_CLUSTER</p>" >>$file_name
	echo "<table WIDTH='90%' BORDER='1'>" >>$file_name
	echo "<tr><th>HOST_NAME</th><th>CLUSTER_SERVICE</th></tr><tr><td>NULL</td><td>NULL</td></tr></table>" >>$file_name
else

#-----Resource_Crs

echo "<p>+ RESOURCE_CRS<p>" >>$file_name
crsctl status resource -v |
egrep -e "NAME|TARGET|STATE|LAST_SERVER|STATE_DETAILS" |
/bin/gawk 'BEGIN {FS="=";}
{
if ($1=="NAME")  resname=$2; else
if ($1=="TARGET") restrg=$2; else
if ($1=="STATE")   resst=$2; else
if ($1=="LAST_SERVER") {
resser=$2
} else
if ($1=="STATE_DETAILS") {
resdet=$2;
if(length($3)!=0) { resdet=resdet"="$3 }
idxx1=index(resst, " "); tat=substr(resst, 0, idxx1);
if (tat=="") {tat="OFFLINE"};
printf "%-35s %-20s %-25s %-20s %-10s\n", resname, restrg, tat, resser, resdet}
}' | $awk 'BEGIN{print("<table WIDTH='90%' BORDER='1'><tr><th>'NAME'<th><th>'TARGET'</th><th>'STATE'</th><th>'LAST_SERVER'</th><th>'STATE_DETAILS'<th></tr>")}
{
	if ($4!=NULL) {
		print("<tr><td>",$1,"</td><td>",$2,"</td><td>",$3,"</td><td>",$4,"<td><td>",$5,$6,$7,$8,"</td></tr>")
	}
}
END{
	print("</table>")
}' >>$file_name

#-----Check_Cluster

echo "<p>+ CHECK_CLUSTER<p>" >>$file_name
crsctl check crs | $awk -v hs=$host 'BEGIN{print("<p><table WIDTH='90%' BORDER='1'><tr><th>HOST_NAME</th><th>CLUSTER_SERVICE</th></tr><tr><td>",hs"</td><td>")}
{
	if ($0!=NULL) {
		print($0,"<br>")
	}
}
END{
	print("</td></tr></table>")
}' >>$file_name
fi

echo
echo "************************"
echo "* Get OS_Command done. *"
echo "************************"
echo

#-----Awrrpt

TEMPFILE=/tmp/tmpawr.sql
echo "<<=====================================================>>"
echo "AWRRPT: @$ORACLE_HOME/rdbms/admin/awrrpt.sql"
echo "<<=====================================================>>"
echo
sqlplus -s / as sysdba <<EOF >/dev/null
set echo off
set head off
set feed off
spool ${TEMPFILE}
select 'define begin_snap = '|| (max(snap_id)-3) from dba_hist_snapshot;
select 'define end_snap = '|| max(snap_id) from dba_hist_snapshot;
select 'define report_type = ' || '''html''' from dual;
select 'define inst_name = ' || INSTANCE_NAME from v\$instance;
select 'define db_name = ' || name from v\$database;
select 'define dbid = ' || dbid from v\$database;
select 'define inst_num = ' || INSTANCE_NUMBER from v\$instance;
select 'define num_days = 1' from dual;
select 'define report_name = awrrpt_${time}_' || INSTANCE_NAME from v\$instance;
select '@$ORACLE_HOME/rdbms/admin/awrrpt.sql' from dual;
spool off
exit
EOF

sqlplus -s / as sysdba <<EOF >/dev/null
@$TEMPFILE
exit
EOF

if [ -f "$TEMPFILE" ]; then
	rm $TEMPFILE
fi
echo
echo "********************"
echo "* Get Awrrpt done. *"
echo "********************"

#-----Get information for report file

# Name, HA/Standalone, Hardware, File system, Archiving, Flashback, Version,Patch, DB size, Backup status

# Name: dbname

# HA/Standalone

rp_ha=$(
sqlplus -s / as sysdba <<EOF
set head off
set feed off
SELECT VALUE FROM $parameter WHERE NAME = 'cluster_database';
exit
EOF
)

rp_ha=$(echo $rp_ha | tr -d '[:space:]')
if [[ "$rp_ha" == 'TRUE' ]]; then
	rp_ha_last='RAC'
else
	rp_ha_last='Stand Alone'
fi

# OS

os1=$(uname -o)
os2=$(uname -m)
os_last="$os1 $os2"

#Hardware

if [[ "$os" == 'Linux' ]]; then
	cpu=$(cat /proc/cpuinfo | grep -c 'core id' | uniq | wc -l)
	ram=$(cat /proc/meminfo | grep MemTotal | tr -dc '0-9')
	ram_last=$(expr "$ram" / 1048576)
else
	cpu=$(psrinfo -p)
	ram=$(prtconf | grep Mem | ggrep -E -o '[0-9]+')
	ram_last=$(expr "$ram" / 1024)
fi
hw_last="CPU: $cpu cores, RAM: $ram_last GB"

#Filesystem

dtf=$(
sqlplus -s / as sysdba <<EOF
set head off
set feed off
select name from $datafile where name like '+%' and rownum=1;
exit
EOF
)

if [[ $dtf == *[+]* ]]; then
	dtf_last="ASM"
else
	dtf_last="File System"
fi

#Archiving Enabled

arc_last=$(
sqlplus -s / as sysdba <<EOF
set head off
set feed off
select (
CASE LOG_MODE
WHEN 'ARCHIVELOG' THEN
'Yes'
ELSE
'No'
END
) ARCHIVELOG from $database;
exit
EOF
)

#Flashback Enabled

fls_last=$(
sqlplus -s / as sysdba <<EOF
set head off
set feed off
select (
CASE FLASHBACK_ON 
WHEN 'YES' THEN
'Yes'
ELSE
'No'
END
) FLASHBACK_MODE from $database;
exit
EOF
)

#Version
ver_last=$(
sqlplus -s / as sysdba <<EOF
set head off
set feed off
select version from $instance;
exit
EOF
)

#Patch

pat_last=$($ORACLE_HOME/OPatch/opatch lspatches | $grep "Database" | $awk -v FS=';' '{print $2}')

#DBsize

size=$(
sqlplus -s / as sysdba <<EOF
set head off
set feed off
select round(sum(bytes)/1024/1024/1024,2) from $datafile;
exit
EOF
)

size_last="$size GB"

#Backup status

bkp_last=$(
sqlplus -s / as sysdba <<EOF
set head off
set feed off
select status from $backupjob where rownum=1;
exit
EOF
)

#Print table

echo "<p>+ REPORT DETAILS</p>" >>$file_name
echo "<table WIDTH='90%' BORDER='1'>" >>$file_name
echo "<tr><th>ITEMS</th><th>INFORMATION</th></tr>" >>$file_name
echo "<tr><td>Name</td><td>$dbname</td></tr>" >>$file_name
echo "<tr><td>HA/Stand Alone</td><td>$rp_ha_last</td></tr>" >>$file_name
echo "<tr><td>OS Version</td><td>$os_last</td></tr>" >>$file_name
echo "<tr><td>Hardware (CPU,RAM)</td><td>$hw_last</td></tr>" >>$file_name
echo "<tr><td>File System/raw devices</td><td>$dtf_last</td></tr>" >>$file_name
echo "<tr><td>Archiving Enabled</td><td>$arc_last</td></tr>" >>$file_name
echo "<tr><td>Flashback Enabled</td><td>$fls_last</td></tr>" >>$file_name
echo "<tr><td>Version</td><td>$ver_last</td></tr>" >>$file_name
echo "<tr><td>Patch</td><td>$pat_last</td></tr>" >>$file_name
echo "<tr><td>DB Size</td><td>$size_last</td></tr>" >>$file_name
echo "<tr><td>Backup status</td><td>$bkp_last</td></tr></table>" >>$file_name
echo
echo "**************************"
echo "* Get Report Infor done. *"
echo "**************************"
echo
echo "End of process!"

#==#==Option 2 (OSWatcher).

elif [ $option == 2 ]; then
	echo
	echo "Setup OSWatcher..."
	echo

#-----Check Java Installation

if java -version 2>&1 >/dev/null | $grep "$java_check"; then
	echo "Java installed!"

	#-----Tar file oswbb840.tar

	tar -xf $pwd/oswbb840.tar -C $pwd/.

	#-----Create folder for oswbb_log

	mkdir -p $pwd/oswbb_log_MPS_$host

	#-----Start oswbb840

	cd $pwd/oswbb
	nohup ./startOSWbb.sh 300 120 None $pwd/oswbb_log_MPS_$host/ >nohup.out 2>&1 &
	echo
	echo

else
	echo "Java NOT installed!"
	echo "Prepare to Install Java!"
fi

	#==#==Option 3 (Exit).

	elif [ $option == 3 ]; then
		echo
		exit
	fi
}

#=====MainStream

Head
while :; do
	Body
	Head
done