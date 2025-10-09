#! /bin/bash

#####
# Versao 2.2

#####
# Script for executing jobs via root
# Usage: scrRootRmanTapeArchive.sh
# Example: ./scrRootRmanTapeArchive.sh

SU=/bin/su

export SCRIPTS_HOME=`dirname $0`

source ${SCRIPTS_HOME}/parRman.sh </dev/null

export ORACLE_BACKUP_TYPE=S3FullOnline

ORACLE_BACKUP_SCRIPT=${ORACLE_BASE}/admin/${ORACLE_DB_NAME}/scripts/backup/scrRman${ORACLE_BACKUP_TYPE}.sh

ORACLE_USER=`ls -l ${ORACLE_BACKUP_SCRIPT} |tr -s " " |cut -f 3 -d " "`

if [ -a "${ORACLE_BACKUP_SCRIPT}" ] ; then
 	$SU - "${ORACLE_USER}" -c "${ORACLE_BACKUP_SCRIPT}"

    OS_OUT_ROO=$?

    echo "OS OUT ROO : "$OS_OUT_ROO

    exit $OS_OUT_ROO
	
else
	echo "Script "${ORACLE_BACKUP_SCRIPT}" does not exist."
	
	echo "OS OUT ROO : 1"
	
	exit 1

fi
