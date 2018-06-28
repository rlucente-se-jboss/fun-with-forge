#!/usr/bin/env bash

. $(dirname $0)/demo.conf

PUSHD $WORKDIR
    rm -fr jboss-eap-*
POPD

