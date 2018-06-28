#!/usr/bin/env bash

. $(dirname $0)/demo.conf

PUSHD $WORKDIR
    echo

    if [ -d "$JBOSS_HOME" ]
    then
        echo "EAP currently installed.  Please remove it before attempting install."
        echo
        exit 1
    fi

    echo -n "Install EAP ..................... "
    unzip -q $BINDIR/jboss-eap-$VER_DIST_EAP.zip
    ISOK

    if [ -n "$VER_PATCH_EAP" ]
    then
        echo -n "Patch EAP ....................... "
        $JBOSS_HOME/bin/jboss-cli.sh \
            --command="patch apply --override-all ${BINDIR}/jboss-eap-${VER_PATCH_EAP}-patch.zip" \
            &> /dev/null
        ISOK
    fi
   
    echo -n "Add PostgreSQL module ........... "
    $JBOSS_HOME/bin/jboss-cli.sh --command="module add --name=org.postgresql \
        --resources=$BINDIR/$PGJDBC --dependencies=javax.api,javax.transaction.api" \
        &> /dev/null
    ISOK

    cat > config-ds.cli <<END1
embed-server --server-config=standalone.xml
/subsystem=datasources/jdbc-driver=postgresql:add(driver-name=postgresql, driver-module-name=org.postgresql, driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource, driver-class-name=org.postgresql.Driver)
data-source add  --name=$PGJNDI --driver-name=postgresql \
    --jndi-name="java:jboss/datasources/$PGJNDI" \
    --connection-url="jdbc:postgresql://localhost:5432/$PGDBNAME" \
    --use-java-context=true --enabled=true \
    --user-name="$PGUSER" --password="$PGPASS" \
    --validate-on-match=true \
    --valid-connection-checker-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker \
    --exception-sorter-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter
stop-embedded-server
END1

    echo -n "Add PostgreSQL datasource ....... "
    $JBOSS_HOME/bin/jboss-cli.sh --file=config-ds.cli &> /dev/null
    ISOK
    rm -f config-ds.cli

    echo -n "Setting admin password .......... "
    ${JBOSS_HOME}/bin/add-user.sh -p "${ADMIN_PASS}" -u "${ADMIN_USER}" --silent
    ISOK

    echo "Done."
    echo
POPD

