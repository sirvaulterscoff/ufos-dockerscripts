#!/bin/bash
echo "#1 building java7"
pushd .
jdk=`docker images otr/oracle-jdk7 | wc -l`
[ $jdk -eq 1 ] && cd java-7 && docker build -t otr/oracle-jdk7:latest .
popd

echo "#2 building jetty"
pushd .
cd ./core/environment/src/main/resources/ && docker build -t otr/jetty:latest .
popd

echo "#3 building sufd-server"
pushd .
cd ./core/sufd-server && mvn docker:build -Pdocker
popd

echo "#4 building func"
pushd .
cd rshn-func && docker build -t otr/rshn-func:latest . 
popd

ehco "5 building db"
pushd .
cd create-db && docker build -t otr/ufos-db .
popd

