#!/bin/bash

. `dirname $0`/demo.conf

echo
PUSHD ${WORK_DIR}
    echo -n "Stop database if running ......... "
    brew services stop postgresql &> /dev/null
    ISOK

    echo -n "Remove existing data ............. "
    rm -fr $PGDATA/*
    ISOK

    echo -n "Initialize the database .......... "
    initdb &> /dev/null
    ISOK

    echo -n "Enable password authentication ... "
    cat >> $PGDATA/pg_hba.conf <<END1
host	$PGDBNAME	$PGUSER	samehost	scram-sha-256
END1
    ISOK

    echo -n "Start the database ............... "
    brew services start postgresql &> /dev/null
    ISOK

    echo -n "Wait for database to start ....... "
    while [ -z "$(brew services list | grep postgresql | grep started)" ]
    do
        sleep 1
    done
    ISOK

    echo -n "Create the user .................. "
    psql -c "CREATE USER $PGUSER WITH PASSWORD '"$PGPASS"';" -d postgres &> /dev/null
    ISOK

    echo -n "Create the database .............. "
    createdb -O $PGUSER $PGDBNAME
    ISOK
POPD
echo "Done."
echo
