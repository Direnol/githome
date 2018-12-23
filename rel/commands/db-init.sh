#!/bin/sh

MYSQL_LOGIN=${1:-root}
MYSQL_PASS=""

if [ -n "${2}" ] ; then
    MYSQL_PASS="--password=${2}"
fi

echo "Create database"
mysql --user="${MYSQL_LOGIN}" ${MYSQL_PASS} -e "create database if not exists githome character set UTF8;"
