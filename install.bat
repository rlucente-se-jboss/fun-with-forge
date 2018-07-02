@REM #!/usr/bin/env bash
@echo off

set ADMIN_USER=admin
set ADMIN_PASS="admin1jboss!"

set VER_DIST_EAP=7.1.0
set VER_INST_EAP=7.1
REM set VER_PATCH_EAP=7.1.3

set PGJDBC=postgresql-42.2.2.jar
set PGDATA=D:\PostgreSQL\10\data
set PGDBNAME=managezoo
set PGUSER=manager
set PGPASS=manager
set PGJNDI=ManageZooDS

set UNZIP=c:\Program Files\7-Zip\7z.exe

REM function ISOK {
REM   if [[ $? -eq 0 ]]
REM   then
REM     echo "[OK]"
REM   else
REM     echo "[FAILED]"
REM   fi
REM }
REM 
REM function PUSHD {
REM   pushd $1 &> /dev/null
REM }
REM 
REM function POPD {
REM   popd &> /dev/null
REM }
REM 
REM PUSHD $(dirname $0)
REM WORKDIR=$(pwd)
REM POPD
set WORKDIR=D:\GitProjects\fun-with-forge

set DISTDIR=%WORKDIR%\dist
set JBOSS_HOME=%WORKDIR%\jboss-eap-%VER_INST_EAP%

set OLD_NOPAUSE=%NOPAUSE%
REM . $(dirname $0)/demo.conf

PUSHD %WORKDIR%

    echo Check Java .....................

	IF ["%JAVA_HOME%"] == [""] (
	echo The JAVA_HOME is not set.
	if "x%OLD_NOPAUSE%" == "x" pause
	exit /b 1
	)

	IF exist "%JAVA_HOME%\" ( 
	echo "The JAVA_HOME (%JAVA_HOME%) currently exists."
	echo     OK
	) ELSE (
	echo "The JAVA_HOME (%JAVA_HOME%) is not currently installed."
	if "x%OLD_NOPAUSE%" == "x" pause
	exit /b 1
	)

    echo Check EAP .....................
	IF exist "%JBOSS_HOME%\" ( 
	echo EAP currently installed in %JBOSS_HOME%.
	echo Please remove it before attempting install.
	if "x%OLD_NOPAUSE%" == "x" pause
	exit /b 1 ) ELSE (
	echo     OK
	)

    echo Install EAP .....................
    "%UNZIP%" x %DISTDIR%\jboss-eap-%VER_DIST_EAP%.zip > nul
	echo     OK

REM    unzip -q $DISTDIR/jboss-eap-$VER_DIST_EAP.zip
REM    ISOK
	
	IF NOT [%VER_PATCH_EAP%] == [] (
        echo "Patch EAP ....................... "
        %JBOSS_HOME%\bin\jboss-cli.bat ^
            --command="patch apply --override-all %DISTDIR%\jboss-eap-%VER_PATCH_EAP%-patch.zip" ^
            > nul
	    echo     OK
	)

REM    if [ -n "$VER_PATCH_EAP" ]
REM     then
REM         echo -n "Patch EAP ....................... "
REM         $JBOSS_HOME\bin\jboss-cli.bat \
REM             --command="patch apply --override-all ${DISTDIR}/jboss-eap-${VER_PATCH_EAP}-patch.zip" \
REM             &> /dev/null
REM         ISOK
REM     fi

    REM set variable NOPAUSE to prevent waiting at the ends of bat scripts
    set NOPAUSE=true

    echo Add PostgreSQL module ........... 
	
	echo module add --name=org.postgresql --resources=%DISTDIR%\%PGJDBC% --dependencies=javax.api,javax.transaction.api > add-pgsql-mod.cli
	
	call %JBOSS_HOME%\bin\jboss-cli.bat --file=add-pgsql-mod.cli > nul
	del add-pgsql-mod.cli
	echo     OK

REM     echo -n "Add PostgreSQL module ........... "
REM     $JBOSS_HOME\bin\jboss-cli.bat --command="module add --name=org.postgresql \
REM         --resources=%DISTDIR%\%PGJDBC% --dependencies=javax.api,javax.transaction.api" \
REM         &> /dev/null
REM     ISOK
REM 

    echo Add PostgreSQL datasource ....... 
    echo # automatically generated script > config-ds.cli
    echo embed-server --server-config=standalone.xml >> config-ds.cli
    echo /subsystem=datasources/jdbc-driver=postgresql:add(driver-name=postgresql, driver-module-name=org.postgresql, driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource, driver-class-name=org.postgresql.Driver) >> config-ds.cli
    echo data-source add  --name=%PGJNDI% --driver-name=postgresql >> config-ds.cli
    echo     --jndi-name="java:jboss/datasources/%PGJNDI%" >> config-ds.cli
    echo     --connection-url="jdbc:postgresql://localhost:5432/%PGDBNAME%" >> config-ds.cli
    echo     --use-java-context=true --enabled=true >> config-ds.cli
    echo     --user-name="%PGUSER%" --password="%PGPASS%" >> config-ds.cli
    echo     --validate-on-match=true >> config-ds.cli
    echo     --valid-connection-checker-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker >> config-ds.cli
    echo     --exception-sorter-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter >> config-ds.cli
    echo stop-embedded-server >> config-ds.cli

    call %JBOSS_HOME%\bin\jboss-cli.bat --file=config-ds.cli > nul
    del config-ds.cli
	echo     OK


REM     cat > config-ds.cli <<END1
REM embed-server --server-config=standalone.xml
REM /subsystem=datasources/jdbc-driver=postgresql:add(driver-name=postgresql, driver-module-name=org.postgresql, driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource, driver-class-name=org.postgresql.Driver)
REM data-source add  --name=$PGJNDI --driver-name=postgresql \
REM     --jndi-name="java:jboss/datasources/$PGJNDI" \
REM     --connection-url="jdbc:postgresql://localhost:5432/$PGDBNAME" \
REM     --use-java-context=true --enabled=true \
REM     --user-name="$PGUSER" --password="$PGPASS" \
REM     --validate-on-match=true \
REM     --valid-connection-checker-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker \
REM     --exception-sorter-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter
REM stop-embedded-server
REM END1
REM 
REM     echo -n "Add PostgreSQL datasource ....... "
REM     $JBOSS_HOME\bin\jboss-cli.bat --file=config-ds.cli &> /dev/null
REM     ISOK
REM     rm -f config-ds.cli

    echo Setting admin password ..........
    call %JBOSS_HOME%\bin\add-user.bat -p "%ADMIN_PASS%" -u "%ADMIN_USER%" --silent
REM     ISOK

REM     echo -n "Setting admin password .......... "
REM     ${JBOSS_HOME}\bin\add-user.sh -p "${ADMIN_PASS}" -u "${ADMIN_USER}" --silent
REM     ISOK
REM 
    echo Done.
POPD
set NOPAUSE=%OLD_NOPAUSE%

if "x%NOPAUSE%" == "x" pause