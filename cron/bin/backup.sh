#!/bin/sh

period=${1:-daily}

if [ $period = daily ]; then
  timestamp=$(date +\%A)
elif [ $period = weekly ]; then
  timestamp=$(date -I)
else
  echo "[ERROR] Unsupported backup period!"
  exit 1
fi

archive=${BACKUP_PATH}/mysql_backup_${timestamp}.sql.gz
echo "[INFO] Backup ${MYSQL_DATABASE} database to ${archive}"

mysqldump -f -u root -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} ${MYSQL_DATABASE} | gzip > ${archive}

if [ $? -ne 0 ]; then
  echo "[ERROR] Backup failed!"
  exit 1
fi

