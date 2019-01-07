#!/bin/bash

DB_USER=${DB_USER:-githome}
DB_PASS=${DB_PASS:-githome}
DB_HOST=${DB_HOST:-db}

until mysql -u"${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" -e '\q' 2>/dev/null ; do
  >&2 echo "Mysql is unavailable - sleeping"
  sleep 1
done

exec ${*}
