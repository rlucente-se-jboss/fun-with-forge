@REM #!/bin/bash
@echo off
REM . `dirname $0`/demo.conf

call demo.conf.bat

REM echo Do not use.
REM echo Re-initialization of the database is not correct
REM echo    added configuration line prevents posgres from starting.
REM pause
REM exit /b 1 

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
	echo postgres> pwdfilename.tmp
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
