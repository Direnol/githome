#!/bin/bash

RES=''
readonly PROGDIR=$(readlink -m "$(dirname "$0")")

LOG_FILE=/tmp/githome_mysql_deploy-$(date --iso-8601).log
echo "Log file: ${LOG_FILE}"
log() {
    echo "$(date -R)=> $1" >> "$LOG_FILE"
}

run_query() {
    query="mysql ${1} ${2} ${3} -ss -q -e \"${4}\" 2>> ${LOG_FILE}"
    log "Run query: ${query}"
    RES=$(mysql "${1}" "${2}" "${3}" -ss -q -e "${4}" 2>> "${LOG_FILE}")
    if [[ $? -ne 0 ]]; then
        echo "Error: ${RES}"
        log "Error: ${RES}"
        exit 1
    fi
    log "DEBUG: |${RES}|"
    return 0
}

run_batch() {
    local BATCH_FILE=${4}
    query="mysql ${1} ${2} ${3} -ss -B -q < $BATCH_FILE 2>> $LOG_FILE"
    log "Run batch: ${query}"
    RES=$(mysql "${1}" "${2}" "${3}" -ss -B -q < "$BATCH_FILE" 2>> "$LOG_FILE")
    if [[ $? -ne 0 ]]; then
        echo "Error. ${RES}"
        log "Error. ${RES}"
        exit 1
    fi
    return 0
}

cancel_with_message() {
    log "${1}"
    log "Installation is canceled."
    echo "Installation is canceled."
    exit 1
}

check_githome_mysql_user() {
    local PASS="${2}"
    if [ "${PASS}" != "~~" ]; then
        PASS="-p${PASS}"
    else
        PASS=""
    fi
    run_query "-u${1}" "${PASS}" "-h${3}" "select distinct user from mysql.user where user='${4}'"
    if [[ "${RES}" == "${4}" ]]; then
        return 0
    else
        return 1
    fi
    return 1
}

create_user() {
    local PASS="${2}"
    if [ "${PASS}" != "~~" ]; then
        PASS="-p${PASS}"
    else
        PASS=""
    fi
    run_query "-u${1}" "${PASS}" "-h${3}" "CREATE USER ${4} IDENTIFIED BY '${5}'"
    if [[ $? -eq 0 ]]; then
        return 0
    fi
    return 1
}

update_password() {
    local PASS="${2}"
    if [ "${PASS}" != "~~" ]; then
        PASS="-p${PASS}"
    else
        PASS=""
    fi

    run_query "-u${1}" "${PASS}" "-h${3}" "UPDATE mysql.user SET authentication_string = PASSWORD('${5}') WHERE user = '${4}';"
    if [[ $? -eq 1 ]]; then
        return 1
    fi
    run_query "-u${1}" "${PASS}" "-h${3}" "flush privileges;"
    if [[ $? -eq 1 ]]; then
        return 1
    fi
    return 0
}

db_grants() {
    local PASS="${2}"
    if [ "${PASS}" != "~~" ]; then
        PASS="-p${PASS}"
    else
        PASS=""
    fi
    local grants=${4}
    local db=${5}
    local host=${6}
    local user=${7}
    local password=${8}
    log "Grant ${grants} for ${db}@${host}"
    if [[ -n "${password}" ]]; then
        run_query "-u${1}" "${PASS}" "-h${3}" "GRANT ${grants}  ON \`$db\`.* TO \`${user}\`@\`${host}\` IDENTIFIED BY '${password}';"
    else
        run_query "-u${1}" "${PASS}" "-h${3}" "GRANT ${grants}  ON \`$db\`.* TO \`${user}\`@\`${host}\`;"
    fi
    run_query "-u${1}" "${PASS}" "-h${3}" "flush privileges;"
}

check_connect() {
    local PASS="${2}"
    if [ "${PASS}" != "~~" ]; then
        PASS="-p${PASS}"
    else
        PASS=""
    fi
    run_query "-u${1}" "${PASS}" "-h${3}" "exit"
    if [[ $? -eq 0 ]]; then
        return 0
    fi
    return 1
}

check_githome_mysql_database() {
    local PASS="${2}"
    if [ "${PASS}" != "~~" ]; then
        PASS="-p${PASS}"
    else
        PASS=""
    fi
    run_query "-u${1}" "${PASS}" "-h${3}" "show databases like 'githome'"
    if [[ -n "$RES" ]]; then
        return 0
    fi
    return 1
}

create_githome_mysql_database() {
    /opt/githome/bin/githome db_init "${1}" "${2}"
    /opt/githome/bin/githome db_migrate
    /opt/githome/bin/githome seed
    if [[ $? -eq 0 ]]; then
        return 0
    fi
    return 1
}

update_grants() {
    GRANTS="CREATE, DELETE, DROP, INSERT, SELECT, UPDATE, EXECUTE, EVENT, ALTER, INDEX"
    db_grants "${1}" "${2}" "${3}" "$GRANTS" "githome" "localhost" "${4}" "${5}"
    db_grants "${1}" "${2}" "${3}" "$GRANTS" "githome" "127.0.0.1" "${4}" "${5}"
}
