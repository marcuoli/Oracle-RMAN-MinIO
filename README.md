
# Oracle-RMAN-MinIO

Oracle RMAN integration with MinIO S3-compatible storage via Oracle Secure Backup (OSB).

This repository contains scripts and configuration files for automating Oracle RMAN backups to S3-compatible storage using MinIO. It includes shell scripts, RMAN command files, and environment configuration for secure, efficient, and flexible backup management.

[Oracle Recovery Manager (RMAN)](https://www.oracle.com/br/database/technologies/high-availability/rman.html)

[docs.min.io](https://docs.min.io/enterprise/aistor-object-store/)  [blog.min.io](https://blog.min.io/)

[Deploy AIStor as a Container](https://docs.min.io/enterprise/aistor-object-store/installation/container/install/)

[Let's Encrypt](https://letsencrypt.org/)

Create a certificate with Let's Encrypt for you MinIO installation. Eg: minio.lan.example.com

```shell
DOCKER_DEST=/var/lib/docker

mkdir -p ${DOCKER_DEST}/minio/data ${DOCKER_DEST}/minio/certs
chown -R 1001:1001 ${DOCKER_DEST}/minio/data

# Copy and rename the certificate files to the certs directory
# fullchain.pem -> public.crt
# privkey.pem -> private.key
# 
# ${DOCKER_DEST}/minio/certs/public.crt
# ${DOCKER_DEST}/minio/certs/private.key

docker run -d \
    --name minio \
    -p 9000:9000 \
    -p 9001:9001 \
    -v ${DOCKER_DEST}/minio/data:/data \
    -v ${DOCKER_DEST}/minio/certs:/etc/minio/certs \
    -e "MINIO_ROOT_USER=<MINIO ADMIN USER NAME> \
    -e "MINIO_ROOT_PASSWORD=<MINIO ADMIN USER PASSWORD> \
    quay.io/minio/minio server /data --address ":9000" --console-address ":9001" --certs-dir /etc/minio/certs
```

Expect this output:
```
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
