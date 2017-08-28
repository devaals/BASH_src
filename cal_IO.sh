#!/bin/bash
#
#Автор: Верещага А.А. 
#Version: 1.0

#Запуск скрипта требует передачи параметров, например:
#./hostcall_io.sh -i isuzht -d 8 -l 10 -v

#######################################################################
# Initialize/Default Variables
#######################################################################
DEBUG='N'
DISKS=20
MAXLATENCY=20
DATADIR=data
DATAFILE=""

#######################################################################
# Function to display usage
#######################################################################
usage()
{

echo "
Usage: -bash [options]

This program executes the DBMS_RESOURCE_MANAGER.CALIBRATE_IO procedure within
Oracle to benchmark the I/O performance and save the information for analysis
over time.

-d   Specify the number of disks in a LUN, DEFAULT 20
-f   Specify the output file, DEFAULT \"data/calibrate_io_stats.csv\"
-h   this help message
-i   instance name REQUIRED
-l   Specify the max latency (in ms), DEFAULT 20
-o   set the ORACLE_HOME directory.
-v   turn on verbose output
"
exit 1
}

#######################################################################
# Function to run the process and grab the results
#######################################################################

RUN_CALIO ()
{
DATA=`${ORACLE_HOME}/bin/sqlplus -s "/ as sysdba" <<EOF
set serverout on size 1000000 linesize 132 pagesize 0 heading off feedback off termout off echo off trimspool on;
WHENEVER SQLERROR EXIT FAILURE;
declare
v_disks pls_integer := ${DISKS};
v_maxlatency pls_integer := ${MAXLATENCY};
v_iops pls_integer;
v_mbps pls_integer;
v_lat pls_integer;

cursor c1 is
select to_char(start_time,'YYYYMMDD HH24:MI:SS') start_time,
to_char(end_time,'YYYYMMDD HH24:MI:SS') end_time,
max_iops,
max_mbps,
max_pmbps,
latency,
num_physical_disks
from dba_rsrc_io_calibrate;

BEGIN
-- first run the procedure
--dbms_resource_manager.calibrate_io(<DISKS>, <MAX LATENCY>, iops, mbps,lat);
dbms_resource_manager.calibrate_io(v_disks, v_maxlatency, v_iops, v_mbps,v_lat);

if nvl(v_iops,0) > 0 then
-- Looks like we have some data
-- get the results in a comma-delimted string

for c1_rec in c1 loop
dbms_output.put_line('${ORACLE_SID}' || ',' || '"' || 
c1_rec.start_time || '","' || c1_rec.end_time || '",' || c1_rec.max_iops || ','
||
c1_rec.max_mbps || ',' || c1_rec.max_pmbps || ',' 
|| c1_rec.latency || ',' || c1_rec.num_physical_disks);
end loop;
end if;
END;
/
EOF`

RC=$?
} # END RUN_CALIO
#######################################################################
#
# MAIN
#
#######################################################################

#######################################################################
# Process the cmd line options
#######################################################################

while getopts d:f:h:i:l:o:v opt
do
case $opt in
d)
DISKS=${OPTARG}
;;
f)
DATAFILE=${OPTARG}
;;
h)
usage
;;
i)
INSTANCE=${OPTARG}
;;
l)
MAX_LATENCY=${OPTARG}
;;
o)
ORACLE_HOME=${OPTARG}
;;
v)
DEBUG='Y'
;;
*)
usage
;;
esac
done
shift $(( OPTIND - 1 ))

# set the oracle home dir and SID
export ORACLE_HOME=${ORACLE_HOME}
export ORACLE_SID=${INSTANCE}

if [ -z ${INSTANCE} ]; then
echo "ERROR: Must pass in instance name"
usage
fi

if [ ! -x ${ORACLE_HOME}/bin/sqlplus ]; then
echo "ERROR: Invalid ORACLE_HOME"
usage
fi

# Default the filename if not passed in
if [ -z "${DATAFILE}" ]; then
# Create the "data" directory if it doesn't exist
if [ ! -d ${DATADIR} ]; then
mkdir ${DATADIR}
fi
DATAFILE=${DATADIR}/calibrate_io_stats.csv
fi

# Run the CalibrateIO procedure
RUN_CALIO
if [ ${RC} -ne 0 ]; then
echo "There was a problem running the Calibrate IO procedure."
echo "${DATA}"
exit ${RC}
elif [ -n "${DATA}" ]; then
# If this is a new datafile, put a header record in first
if [ ! -w ${DATAFILE} ]; then
echo "INSTANCE, START TIME, END TIME, MAX_IOPS, MAX_MBPS, MAX_PMBPS, 
LATENCY, DISKS" > ${DATAFILE}
fi

echo "${DATA}" >> ${DATAFILE}

if ["${DEBUG}" == "Y" ]; then
echo "instance, start time, end time, max_iops, max_mbps, max_pmbps, latency, disks"
echo "${DATA}"
fi

exit 0
else
# We had a problem somewhere so exit with non-zero return code
exit 1
fi
