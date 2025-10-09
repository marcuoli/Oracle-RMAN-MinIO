
# Oracle-RMAN-MinIO

Oracle RMAN integration with MinIO S3-compatible storage via Oracle Secure Backup (OSB).

This repository contains scripts and configuration files for automating Oracle RMAN backups to S3-compatible storage using MinIO. It includes shell scripts, RMAN command files, and environment configuration for secure, efficient, and flexible backup management.

[Oracle Recovery Manager (RMAN)](https://www.oracle.com/br/database/technologies/high-availability/rman.html)

[docs.min.io](https://docs.min.io/enterprise/aistor-object-store/)  [blog.min.io](https://blog.min.io/)

[Deploy AIStor as a Container](https://docs.min.io/enterprise/aistor-object-store/installation/container/install/)

[Let's Encrypt](https://letsencrypt.org/)

Create a certificate with Let's Encrypt for you MinIO installation. Eg: minio.lan.example.com

```shell
DOCKER_DEST=${DOCKER_DEST}

mkdir -p ${DOCKER_DEST}/minio/data ${DOCKER_DEST}/minio/certs
chown -R 1001:1001 ${DOCKER_DEST}/minio/data

# Copy and rename the certificate files to the certs directory
# fullchain.pem -> public.crt
# privkey.pem -> private.key
# 
# ${DOCKER_DEST}/minio/certs/public.crt
# ${DOCKER_DEST}/minio/certs/private.key

docker run -d \
    -p 9000:9000 \
    -p 9001:9001 \
    --name minio \
    -v ${DOCKER_DEST}/minio/data:/data \
    -v ${DOCKER_DEST}/minio/certs:/etc/minio/certs \
    -e "MINIO_ROOT_USER=<span style=\"color:black;\">&lt;ADMIN USER NAME&gt;</span>" \
    -e "MINIO_ROOT_PASSWORD=<span style=\"color:red;\"><b><em>ADMIN PASSWORD</em></b></span>" \
    quay.io/minio/minio server /data --address ":9000" --console-address ":9001" --certs-dir /etc/minio/certs
```
