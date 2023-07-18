#!/bin/ksh

#-----Declare variable for script
host=$(hostname)
os=$(uname)
fmy=$(mysql --help | grep /my.cnf | xargs ls)

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
	$cnn_str -se "SELECT schema_name from INFORMATION_SCHEMA.SCHEMATA  WHERE schema_name NOT IN('information_schema', 'mysql', 'performance_schema', 'sys');"
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

	#-----Choose Database
    echo "===============>>"
	echo " <> LIST DATABASE :" $dbnames " / 1: Exit"
    if [[ "$os" == 'Linux' ]]; then
	read -p " <> DATABASE_NAME : " dbname
    else
	read dbname?" <> DATABASE_NAME : "
    fi

	if [[ "$dbname" == 1 ]]; then
	echo
	exit
	else
	dbname=$dbname
	fi

    echo "<<==============="

    #-----Create folder
    mkdir -p $pwd/${dbname}
    cd $pwd/${dbname}

	echo
	echo ">>--------------------------- *** ---------------------------<<"
	echo "<<========================<<  MPS  >>========================>>"
	echo ">>--------------------------- *** ---------------------------<<"
	echo
	echo " <> OS Machine  :" $os
	echo " <> Date Time   :" $time
	echo " <> Script      :" $pwd
    echo " <> List DB     :" $dbnames
	echo " <> DB Name     :" $dbname
	echo " <> Data Dir    :" $dbhome$dbname
	echo " <> File my.cnf :" $fmy
#	echo " <> Alert Log   :" $spwd
	echo " <> OSWbb Log   :" $pwd/oswbb_log_MPS_$host
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

#-----database_information
file_name='database_information.html'
touch database_information.html

#--Header
echo "<html>
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=US-ASCII\">
<meta name=generator content=\"SQL*Plus 12.2.0\">
<TITLE>DATABASE INFORMATION</TITLE>  <STYLE TYPE='TEXT/CSS'></STYLE>
</head>
<body TEXT='#FF0000'>" >>$file_name

#--Check Database Name & Size

echo "<p>+ DATABASE_INFORMATION</p>" >>$file_name
$cnn_str -H -se "
SELECT 
    TABLE_SCHEMA 'DATABASE NAME', 
    (SELECT mysql_version FROM sys.version) 'VERSION',
    CONCAT(ROUND(SUM(INDEX_LENGTH+DATA_LENGTH)/1024/1024/1024,2)) 'DATABASE SIZE (GB)'
FROM 
    INFORMATION_SCHEMA.TABLES 
WHERE 
    TABLE_SCHEMA='$dbname';" >>$file_name

#--Check Log Variable Status
echo "<p>+ LOG_VARIABLE</p>" >>$file_name
$cnn_str -H -se "
SELECT
    VARIABLE_NAME 'LOG TYPE',
    VARIABLE_VALUE 'LOG STATUS'
FROM
    performance_schema.global_variables
WHERE
    VARIABLE_NAME IN ('log_error','binlog_error_action','general_log','general_log_file','slow_query_log','slow_query_log_file');" >>$file_name

#--Check Error Log
echo "<p>+ ERROR_LOG</p>" >>$file_name
$cnn_str -H -se "
SELECT
    *
FROM
    performance_schema.error_log
ORDER BY
    LOGGED DESC LIMIT 30;" >>$file_name

#--Check Table Information
echo "<p>+ TABLE_INFORMATION</p>" >>$file_name
$cnn_str -H -se "
SELECT 
    CONCAT(TABLE_NAME) as 'TABLE',
    ENGINE,
    CONCAT(ROUND(TABLE_ROWS/1000000,2), 'M') 'ROWS',
    CONCAT(ROUND(DATA_LENGTH/1024/1024,2)) 'DATA (MB)',
    CONCAT(ROUND(INDEX_LENGTH/1024/1024,2)) 'IDX (MB)',
    CONCAT(ROUND(DATA_LENGTH + INDEX_LENGTH)/1024/1024,2) 'TOTAL SIZE (MB)',
    ROUND(INDEX_LENGTH/DATA_LENGTH,2) IDXFRAC,
    ROUND(DATA_FREE/(INDEX_LENGTH+DATA_LENGTH)*100) 'FRAG RATIO (%)'
FROM 
    INFORMATION_SCHEMA.TABLES
WHERE 
    TABLE_SCHEMA='$dbname'
ORDER BY 
    DATA_LENGTH+INDEX_LENGTH DESC;" >>$file_name

#--Check Database File System Information
echo "<p>+ DATABASE_FILE_SIZE</p>" >>$file_name
echo "<p>+ DB_FILE_SIZE</p>" >>$file_name
du -sh $dbhome/$dbname/* | $awk 'BEGIN{print("<table BORDER='1'><tr><th>'FILENAME'</th><th>'SIZE'</th></tr>")}
{
	print("<tr><td>",$2,"</td><td>",$1,"</td></tr>")
}
END{
	print("</table><p><p>")
}' >>$file_name

#--Check Table Partition Status
echo "<p>+ TABLE_PARTITION</p>" >>$file_name
$cnn_str -H -se "
SELECT
    TABLE_NAME 'TABLE OWNER',
    PARTITION_NAME 'PARTITION NAME',
    CONCAT(ROUND(DATA_LENGTH/1024/1024,2)) 'DATA SIZE (MB)',
    CONCAT(ROUND(INDEX_LENGTH/1024/1024,2)) 'INDEX SIZE (MB)',
    CONCAT(ROUND(DATA_FREE/1024/1024,2)) 'DATA FREE (MB)'
FROM
    INFORMATION_SCHEMA.PARTITIONS
WHERE
    TABLE_SCHEMA='$dbname'
ORDER BY
    DATA_FREE DESC;" >>$file_name

#--Check Invalid View
echo "<p>+ INVALID_VIEW</p>" >>$file_name
$cnn_str -H -se "
SELECT 
    TABLE_NAME
FROM 
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA='$dbname'
    AND TABLE_TYPE='view'
    AND TABLE_ROWS IS NULL
    AND TABLE_COMMENT LIKE '%invalid%';" >>$file_name

#--Check Table Statistics
echo "<p>+ TABLE_STATISTICS</p>" >>$file_name
$cnn_str -H -se "
SELECT
    TABLE_NAME 'TABLE NAME',
    UPDATE_TIME 'DATE'
FROM
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA='$dbname'
    AND UPDATE_TIME IS NOT NULL
UNION ALL 
    SELECT 
        'NULL',
        '01/01/2000 01:00'
    FROM 
        DUAL
ORDER BY ISNULL('DATE'), 'DATE' DESC;" >>$file_name

#--Check Unused Indexes
echo "<p>+ UNUSED INDEXES</p>" >>$file_name
$cnn_str -H -se "
SELECT
    object_schema 'DATABASE',
    object_name 'TABLE NAME',
    index_name 'INDEX NAME'
FROM 
    sys.schema_unused_indexes 
WHERE 
    index_name NOT LIKE 'fk_%'
    AND object_schema='$dbname';" >>$file_name

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
sort -rn -k 5 ) | $awk 'BEGIN{print("<table BORDER='1'><tr><th>'FILESYSTEM'</th><th>'SIZE'</th><th>'USED'</th><th>'AVAIL'</th><th>'USE%'</th><th>'MOUNTED_ON'</th></tr>")}
{
	if ($2!="0K" && $2!="Size") {
		print("<tr><td>",$1,"</td><td>",$2,"</td><td>",$3,"</td><td>",$4,"</td><td>",$5,"</td><td>",$6,$7,"</td></tr>")
	}
}
END{
	print("</table><p><p>")
}' >>$file_name

echo "</body>" >>$file_name

sed -i 's/table BORDER=1/table WIDTH=90% BORDER=1/g' $file_name
sed -i 's/TABLE BORDER=1/table WIDTH=90% BORDER=1/g' $file_name

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