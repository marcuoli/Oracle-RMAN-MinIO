#!/bin/bash

#####
# Versao 2.2

source /u01/scripts/oraenv_19_oracle_db_1.sh </dev/null

# Common parameters for RMAN scripts
export NLS_DATE_FORMAT="DD/MM/YYYY HH24:MI:SS"

export ORACLE_SID=<ORACLE_SID>
export ORACLE_DB_NAME=<ORACLE_DB_NAME>

export ORACLE_SYSDBA_USER=<SYSDBA_USER>
export ORACLE_SYSDBA_PASS=<SYSDBA_PASSWORD>

export CATALOG_USER=<CATALOG_USER>
export CATALOG_PASS=<CATALOG_PASSWORD>
export CATALOG_TNS=<TNS ENTRY/EASY CONNECT STRING>

export CATALOG_USER_BKP=<CATALOG_BKP_USER>
export CATALOG_PASS_BKP=<CATALOG_BKP_PASSWORD>
export CATALOG_TNS_BKP=<BKP TNS ENTRY/EASY CONNECT STRING>

export RMAN_BACKUP_ARCH_PARALLELISM=2
export RMAN_BACKUP_FULL_PARALLELISM=2

export RMAN_BACKUP_RECOVERY_WINDOW=7
export LOG_RETENTION=62

export ORACLE_DB_BLOCK_SIZE=<DB BLOCK SIZE>

# OSB (MinIO)
export RMAN_S3_SBT_LIBRARY=${ORACLE_HOME}/lib/libosbws.so
export RMAN_S3_OSB_WS_PFILE=${ORACLE_BASE}/admin/${ORACLE_DB_NAME}/osb/osbws${ORACLE_DB_NAME}.ora

# Determine MAXSETSIZE based on DB_BLOCK_SIZE
# export ORACLE_DB_BLOCK_SIZE=`grep -i db_block_size $ORACLE_HOME/dbs/init${ORACLE_SID}.ora |grep -v "^#" |cut -f 2 -d "=" |sed s/" "//g`
case "${ORACLE_DB_BLOCK_SIZE}" in
        2048)
                ORACLE_MAXSETSIZE="4G"
                ;;
        4096)
                ORACLE_MAXSETSIZE="8G"
                ;;
        8192)
                ORACLE_MAXSETSIZE="32G"
                ;;
        16384)
                ORACLE_MAXSETSIZE="64G"
                ;;
        32768)
                ORACLE_MAXSETSIZE="128G"
                ;;
        *)
                ORACLE_MAXSETSIZE="4G" # Default value for unknown block size
                ;;
esac

export ORACLE_MAXSETSIZE

# Determine RMAN_INCREMENTAL_LEVEL based on day of the week (0=Sunday, 6=Saturday)
# Full backup on Saturday (6), Incremental Level 1 on other days
if [ "$(date +'%w')" == 6 ] ; then RMAN_INCREMENTAL_LEVEL="0" ; else RMAN_INCREMENTAL_LEVEL="1" ; fi

export RMAN_INCREMENTAL_LEVEL