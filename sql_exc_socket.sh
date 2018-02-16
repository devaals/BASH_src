#!/bin/bash

DBName=$1
DBUSER=$2
psql -d $DBName « EOF
ALTER ROLE $DBUSER CONNECTION LIMIT 0;
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$DBName' AND pid <> pg_backend_pid();
EOF

sleep 900

psql -d $DBName « EOF
ALTER ROLE $DBUSER CONNECTION LIMIT -1;
EOF