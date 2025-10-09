
# Oracle-RMAN-MinIO

Oracle RMAN integration with MinIO S3-compatible storage via Oracle Secure Backup (OSB).

This repository contains scripts and configuration files for automating Oracle RMAN backups to S3-compatible storage using MinIO. It includes shell scripts, RMAN command files, and environment configuration for secure, efficient, and flexible backup management.

[Oracle Recovery Manager (RMAN)](https://www.oracle.com/br/database/technologies/high-availability/rman.html)

[MinIO docs](https://docs.min.io/enterprise/aistor-object-store/)  [MinIO blog](https://blog.min.io/)

[Deploy AIStor as a Container](https://docs.min.io/enterprise/aistor-object-store/installation/container/install/)

[Let's Encrypt TLS Certificates](https://letsencrypt.org/)

Create a certificate with Let's Encrypt for your MinIO installation. Example: minio.lan.example.com

```shell
DOCKER_DEST=/var/lib/docker

mkdir -p ${DOCKER_DEST}/minio/data ${DOCKER_DEST}/minio/certs
chown -R 1001:1001 ${DOCKER_DEST}/minio/data


# Copy and rename the certificate files to the certs directory:
#   fullchain.pem → public.crt
#   privkey.pem   → private.key
#   ${DOCKER_DEST}/minio/certs/public.crt
#   ${DOCKER_DEST}/minio/certs/private.key

MINIO_ROOT_USER=<MINIO_ADMIN_USERNAME>
MINIO_ROOT_PASSWORD=<MINIO_ADMIN_USER_PASSWORD>

docker run -d \
    --name minio \
    -p 9000:9000 \
    -p 9001:9001 \
    -v ${DOCKER_DEST}/minio/data:/data \
    -v ${DOCKER_DEST}/minio/certs:/etc/minio/certs \
    -e "MINIO_ROOT_USER=${MINIO_ROOT_USER}$ \
    -e "MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}$ \
    quay.io/minio/minio server /data --address ":9000" --console-address ":9001" --certs-dir /etc/minio/certs
```

You should see output similar to:

```shell
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
docker exec -it minio mc mb local/oracle-backups

    [root@docker-host ~]# docker exec -it minio mc mb local/oracle-backups
    Bucket created successfully `local/oracle-backups`.
    [root@docker-host ~]#
```
