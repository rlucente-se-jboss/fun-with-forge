@REM #!/bin/bash
@echo off
REM . `dirname $0`/demo.conf


set ADMIN_USER=admin
set ADMIN_PASS="admin1jboss!"

set VER_DIST_EAP=7.1.0
set VER_INST_EAP=7.1
set VER_PATCH_EAP=7.1.3

set PGJDBC=postgresql-42.2.2.jar
REM set PGDATA=/usr/local/var/postgres
set PG_HOME=D:\PostgreSQL\10
set PGDATA=%PG_HOME%\data
set PGSERV=postgresql-x64-10
set PGDBNAME=managezoo
set PGUSER=manager
set PGPASS=manager
set PGJNDI=ManageZooDS

REM function echo     OK {
REM   if [[ $? -eq 0 ]]
REM   then
REM     echo "[OK]"
REM   else
REM     echo "[FAILED]"
REM   fi
REM }

REM function PUSHD {
REM   pushd $1 &> /dev/null
REM }

REM function POPD {
REM   popd &> /dev/null
REM }

REM PUSHD $(dirname $0)
REM WORKDIR=$(pwd)
REM POPD
set WORKDIR=D:\GitProjects\fun-with-forge

set BINDIR=%WORKDIR%\dist
set JBOSS_HOME=%WORKDIR%\jboss-eap-%VER_INST_EAP%



echo Do not use.
echo Re-initialization of the database is not correct
echo    added configuration line prevents posgres from starting.
pause
exit /b 1 

PUSHD %WORK_DIR%
    echo "Stop database if running ......... "
	net stop %PGSERV%
REM    services stop postgresql > nul
    echo     OK

    echo "Remove existing data ............. "
	del /q "%PGDATA%\*"
    FOR /D %%p IN ("%PGDATA%\*") DO rmdir "%%p" /s /q
REM    rm -fr %PGDATA%\*
    echo     OK

    echo "Initialize the database .......... "
	echo "postgres" > pwdfilename.tmp
    %PG_HOME%\bin\initdb.exe -U postgres -A password -E utf8 --pwfile=pwdfilename.tmp > nul
	del pwdfilename.tmp
    echo     OK

    echo "Enable password authentication ... "
	echo host	%PGDBNAME%	%PGUSER%	samehost	scram-sha-256 >> %PGDATA%\pg_hba.conf
REM     cat >> $PGDATA/pg_hba.conf <<END1
REM host	$PGDBNAME	$PGUSER	samehost	scram-sha-256
REM END1
    echo     OK

    echo "Start the database ............... "
	net start %PGSERV%
REM    brew services start postgresql &> /dev/null
    echo     OK

REM    echo "Wait for database to start ....... "
REM    while [ -z "$(brew services list | grep postgresql | grep started)" ]
REM    do
REM        sleep 1
REM    done
REM    echo     OK

    echo "Create the user .................. "
    %PG_HOME%\bin\psql.exe -c "CREATE USER %PGUSER% WITH PASSWORD '"%PGPASS%"';" -d postgres > nul
    echo     OK

    echo "Create the database .............. "
    %PG_HOME%\bin\createdb.exe -O %PGUSER% %PGDBNAME%
    echo     OK
POPD
echo "Done."
echo
