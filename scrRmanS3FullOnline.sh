#!/bin/bash

#####
# Version 2.2

set +x

export SCRIPTS_HOME=`dirname $0`

source ${SCRIPTS_HOME}/parRman.sh </dev/null

export ORACLE_BACKUP_TYPE=S3FullOnline

export RMAN_CMDFILE=${ORACLE_BASE}/admin/${ORACLE_DB_NAME}/scripts/backup/cmdRman${ORACLE_BACKUP_TYPE}.rcv
export RMAN_LOGFILE=${ORACLE_BASE}/admin/${ORACLE_DB_NAME}/scripts/backup/log/logRman${ORACLE_BACKUP_TYPE}-`date +"%d-%m-%Y_%H.%M"`.log
export RMAN_LCKFILE=${ORACLE_BASE}/admin/${ORACLE_DB_NAME}/scripts/backup/.lckRman${ORACLE_BACKUP_TYPE}.lock
export RMAN_EXITCOD=0

export RMAN_EM_EXEC=`fuser ${ORACLE_BASE}/admin/${ORACLE_DB_NAME}/scripts/backup/scrRman${ORACLE_BACKUP_TYPE}.sh 2>/dev/null |wc -w`

if [ ! -e ${RMAN_LCKFILE} -o ${RMAN_EM_EXEC} -le 1 ] ; then
        date >> ${RMAN_LCKFILE}

        source ${SCRIPTS_HOME}/cmdRman${ORACLE_BACKUP_TYPE}.rcv

        rm ${RMAN_LCKFILE}

	echo "OS OUT SCR : "${RMAN_EXITCOD}     >> ${RMAN_LOGFILE}

        tail -512 ${RMAN_LOGFILE}

else
        echo "Backup RMAN do banco ${ORACLE_DB_NAME} tipo ${ORACLE_BACKUP_TYPE} em andamento desde " $(cat ${RMAN_LCKFILE})
        
	echo "OS OUT SCR : 1" >> ${RMAN_LOGFILE}

        RMAN_EXITCOD=1

fi

find ${ORACLE_BASE}/admin/${ORACLE_DB_NAME}/scripts/backup/log/ -name "logRman${ORACLE_BACKUP_TYPE}*" -mtime ${LOG_RETENTION:-62} -exec zip -9m ${ORACLE_BASE}/admin/${ORACLE_DB_NAME}/scripts/backup/log/logRman${ORACLE_BACKUP_TYPE}.zip {} \;

exit $RMAN_EXITCOD
