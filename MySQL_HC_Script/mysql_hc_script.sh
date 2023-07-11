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

#-----database_information
file_name='database_information.html'
touch database_information.html
echo "<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
<meta name="generator" content="SQL*Plus 12.2.0">
<TITLE>DATABASE INFORMATION</TITLE>  <STYLE TYPE='TEXT/CSS'>  <!-- BODY {BACKGROUND: #FFFFE6} -->  </STYLE>
</head>
<body TEXT='#FF0000'>" >>$file_name

#--Check Table Information
$cnn_str -H -se "SELECT CONCAT(table_name) as 'TABLE',
ENGINE,
CONCAT(ROUND(table_rows/1000000,2), 'M') 'ROWS',
CONCAT(ROUND(data_length/1024/1024,2)) 'DATA (MB)',
CONCAT(ROUND(index_length/1024/1024,2)) 'IDX (MB)',
CONCAT(ROUND(data_length + index_length)/1024/1024,2) 'TOTAL SIZE (MB)',
ROUND(index_length / data_length,2) IDXFRAC
FROM information_schema.TABLES
WHERE TABLE_SCHEMA='$dbname'
ORDER BY data_length + index_length DESC;" >>$file_name

#-----OS_Command

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

#-----Check_Patches

echo "<p>+ CHECK_PATCHES</p>" >>$file_name

#-----Backup_Policy

echo "<p>+ BACKUP_POLICY</p>" >>$file_name

echo "</body>" >>$file_name

#-----Get information for report file

# Name, HA/Standalone, Hardware, File system, Archiving, Flashback, Version,Patch, DB size, Backup status

# Name: dbname

# HA/Standalone

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

#Archiving Enabled

#Flashback Enabled

#Version

#Patch

#DBsize

#Backup status

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