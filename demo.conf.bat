
set ADMIN_USER=admin
set ADMIN_PASS="admin1jboss!"

set VER_DIST_EAP=7.1.0
set VER_INST_EAP=7.1
set VER_PATCH_EAP=7.1.3

set PGJDBC=postgresql-42.2.2.jar
set PG_HOME=D:\PostgreSQL\10
set PGDATA=%PG_HOME%\data
set PGDBNAME=managezoo
set PGUSER=manager
set PGPASS=manager
set PGJNDI=ManageZooDS

REM function ISOK {
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
REM The windows have some obsure ways to get dir info, hard coding value instead 
set WORKDIR=D:\GitProjects\fun-with-forge

set DISTDIR=%WORKDIR%\dist

REM IF NOT ["%JBOSS_HOME%"] == [""] (
REM echo "The JBOSS_HOME is already set (%JBOSS_HOME%)."
REM if "x%OLD_NOPAUSE%" == "x" pause
REM exit /b 1
REM )

set JBOSS_HOME=%WORKDIR%\jboss-eap-%VER_INST_EAP%

