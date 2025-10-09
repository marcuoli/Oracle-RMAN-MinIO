
# Oracle-RMAN-MinIO

Oracle RMAN integration with MinIO S3-compatible storage via Oracle Secure Backup (OSB).

This repository contains scripts and configuration files for automating Oracle RMAN backups to S3-compatible storage using MinIO. It includes shell scripts, RMAN command files, and environment configuration for secure, efficient, and flexible backup management.

[Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/)

[Oracle Recovery Manager (RMAN)](https://www.oracle.com/br/database/technologies/high-availability/rman.html)

[MinIO docs](https://docs.min.io/enterprise/aistor-object-store/)  [MinIO blog](https://blog.min.io/)

[Deploy AIStor as a Container](https://docs.min.io/enterprise/aistor-object-store/installation/container/install/)

[Let's Encrypt TLS Certificates](https://letsencrypt.org/)

Create a certificate with Let's Encrypt for your MinIO installation ( [How It Works](https://letsencrypt.org/how-it-works/) ). Example: minio.lan.example.com.

## MinIO docker container setup

```shell
DOCKER_DEST=/var/lib/docker

mkdir -p ${DOCKER_DEST}/minio/data ${DOCKER_DEST}/minio/certs
chown -R 1001:1001 ${DOCKER_DEST}/minio/data

# Copy and rename the Let's Encrypt certificate files to the certs directory:
#   fullchain.pem → public.crt
#   privkey.pem   → private.key
#   ${DOCKER_DEST}/minio/certs/public.crt
#   ${DOCKER_DEST}/minio/certs/private.key

MINIO_ROOT_USER=admin        <-- Just an example
MINIO_ROOT_PASSWORD=welcome1 <-- Just an example

docker run -d \
    --name minio \
    -p 9000:9000 \
    -p 9001:9001 \
    -v ${DOCKER_DEST}/minio/data:/data \
    -v ${DOCKER_DEST}/minio/certs:/etc/minio/certs \
    -e "MINIO_ROOT_USER=${MINIO_ROOT_USER} \
    -e "MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD} \
    quay.io/minio/minio server /data --address ":9000" --console-address ":9001" --certs-dir /etc/minio/certs
```

You should see output similar to:

```shell
docker logs -f minio

    [root@docker-host ~]# docker logs -f minio
    INFO: Formatting 1st pool, 1 set(s), 1 drives per set.
    INFO: WARNING: Host local has more than 0 drives of set. A host failure will result in data becoming unavailable.
    MinIO Object Storage Server
    Copyright: 2015-2025 MinIO, Inc.
    License: GNU AGPLv3 - https://www.gnu.org/licenses/agpl-3.0.html
    Version: RELEASE.2025-09-07T16-13-09Z (go1.24.6 linux/amd64)

    API: https://10.0.3.3:9000  https://127.0.0.1:9000
    WebUI: https://10.0.3.3:9001 https://127.0.0.1:9001

    Docs: https://docs.min.io
```

```shell
docker exec -it minio mc alias set local https://minio.lan.example.com:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

    [root@docker-host ~]# docker exec -it minio mc alias set local https://minio.lan.example.com:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}
    Added `local` successfully.
    [root@docker-host ~]#
```

Show MinIO information:

```shell
docker exec -it minio mc admin info local

    [root@docker-host ~]# docker exec -it minio mc admin info local
    ●  minio.lan.example.com:9000
       Uptime: 6 minutes
       Version: 2025-09-07T16:13:09Z
       Network: 1/1 OK
       Drives: 1/1 OK
       Pool: 1

    ┌──────┬────────────────────────┬─────────────────────┬──────────────┐
    │ Pool │ Drives Usage           │ Erasure stripe size │ Erasure sets │
    │ 1st  │ 71.0% (total: 9.9 TiB) │ 1                   │ 1            │
    └──────┴────────────────────────┴─────────────────────┴──────────────┘

    1 drive online, 0 drives offline, EC:0       
```

Create the bucket to hold the backup files:

```shell
MINIO_BUCKET=oracle-backups

docker exec -it minio mc mb local/${MINIO_BUCKET}

    [root@docker-host ~]# docker exec -it minio mc mb local/oracle-backups
    Bucket created successfully `local/oracle-backups`.
    [root@docker-host ~]#
```

```shell
docker exec -it minio mc anonymous set public local/oracle-backups

    [root@docker-host ~]# docker exec -it minio mc anonymous set public minio/oracle-backups
    Access permission for `minio/oracle-backups` is set to `public`
    [root@docker-host ~]#
```

## Oracle RMAN configuration

Depending on the Oracle version and platform, the Oracle MML library may already be available in your installation at ${ORACLE_HOME}/lib/libosbws.so. In this case, you do not need to download it; simply omit the -libDir option when running osbws_install.jar.

```shell
ORACLE_DB_NAME=orcl         <-- Just an example
ORACLE_BASE=/u01/app/oracle <-- Just an example

OSBWS_LIB_LOCATION=/tmp/osbws_install.jar <-- Just an example
OSBWS_RMAN_CONFIG=${ORACLE_BASE}/admin/${ORACLE_DB_NAME}/osb/osbws${ORACLE_DB_NAME}.ora <-- Just an example
OSBWS_WALLET_DIR=${ORACLE_BASE}/admin/${ORACLE_DB_NAME}/osb/wallet <-- Just an example

java -jar ${OSBWS_LIB_LOCATION} \
  -awsEndPoint minio.lan.example.com \
  -awsPort 9000 \
  -configFile ${OSBWS_RMAN_CONFIG} \
  -AWSID ${MINIO_ROOT_USER} \
  -AWSKey ${MINIO_ROOT_PASSWORD} \
  -location ${MINIO_BUCKET} \
  -walletDir ${OSBWS_WALLET_DIR} \
  -useSigV2 -useHttps

    [oracle@acst:~] $ java -jar /tmp/osbws_install.jar \
      -awsEndPoint minio.lan.example.com \
      -awsPort 9000 \
      -configFile /u01/app/oracle/admin/orcl/osb/osbwsorcl.ora \
      -AWSID admin \
      -AWSKey welcome1 \
      -location local/oracle-backups \
      -walletDir /u01/app/oracle/admin/orcl/osb/wallet \
      -useSigV2 \
      -useHttps
    Oracle Secure Backup Web Service Install Tool, build 12.2.0.1.0DBBKPCSBP_2018-06-12
    AWS credentials are valid.
    Oracle Secure Backup Web Service wallet created in directory /u01/app/oracle/admin/orcl/osb/wallet.
    Oracle Secure Backup Web Service initialization file /u01/app/oracle/admin/orcl/osb/osbwsorcl.ora created.
    Skipping library download because option -libDir is not specified.
    [oracle@acst:~] $
```

The contents of the file ${OSBWS_RMAN_CONFIG} should be as follows:

```shell
OSB_WS_HOST=https://minio.lan.example.com:9000
OSB_WS_BUCKET=oracle-backups
# OSB_WS_LOCATION=on-prem
OSB_WS_VIRTUAL_HOST=FALSE
_OSB_WS_AUTH_SCHEME=AWS
OSB_WS_WALLET='location=file:/u01/app/oracle/admin/orcl/osb/wallet CREDENTIAL_ALIAS=minio_aws'
```

## Oracle RMAN Backup execution

The script below is just an example. The only difference in your script should be the channel allocation, which can be configured in various ways (for example, by using "CONFIGURE CHANNEL...").

```sql
    RUN {
        allocate channel osb_01 
            device type sbt 
            parms='SBT_LIBRARY=/u01/app/oracle/product/19/db_1/lib/libosbws.so,SBT_PARMS=(OSB_WS_PFILE=/u01/app/oracle/admin/orcl/osb/osbwsorcl.ora)';

        backup tablespace SYSTEM;

        release channel osb_01;
    }
```

You should see output similar to:

```shell
    RMAN> RUN {
            allocate channel osb_01
                device type sbt
                parms='SBT_LIBRARY=/u01/app/oracle/product/19/db_1/lib/libosbws.so,SBT_PARMS=(OSB_WS_PFILE=/u01/app/oracle/admin/orcl/osb/osbwsorcl.ora)';

            backup tablespac e SYSTEM;

            release channel osb_01;
        }
    {
    3>         allocate channel osb_01
    4>             device type sbt
    5>             parms='SBT_LIBRARY=/u01/app/oracle/product/19/db_1/lib/libosbws.so,SBT_PARMS=(OSB_WS_PFILE=/u01/app/oracle/admin/orcl/osb/osbwsorcl.ora)';
    6>
    7>         backup tablespace SYSTEM;
    8>
    9>         release channel osb_01;
    10>     }
    allocated channel: osb_01
    channel osb_01: SID=24 device type=SBT_TAPE
    channel osb_01: Oracle Secure Backup Web Services Library VER=19.0.0.1

    Starting backup at 09/10/2025 19:22
    channel osb_01: starting full datafile backup set
    channel osb_01: specifying datafile(s) in backup set
    input datafile file number=00001 name=/u01/app/oracle/oradata/orcl/datafile/o1_mf_system_lw74lfg6_.dbf
    channel osb_01: starting piece 1 at 09/10/2025 19:22
    channel osb_01: finished piece 1 at 09/10/2025 19:23
    piece handle=qf45qvn1_23375_1_1 tag=TAG20251009T192252 comment=API Version 2.0,MMS Version 19.0.0.1
    channel osb_01: backup set complete, elapsed time: 00:00:35
    Finished backup at 09/10/2025 19:23

    Starting Control File and SPFILE Autobackup at 09/10/2025 19:23
    piece handle=orcl_cfile_auto_c-1269851242-20251009-0e comment=API Version 2.0,MMS Version 19.0.0.1
    Finished Control File and SPFILE Autobackup at 09/10/2025 19:23

    released channel: osb_01


    RMAN>
```
