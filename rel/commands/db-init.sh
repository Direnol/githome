#!/bin/sh

MYSQL_LOGIN=${1}
MYSQL_PASS=${2}

mysql --user="${MYSQL_LOGIN}" --password="${MYSQL_PASS}" -e "create database if not exists githome;"
