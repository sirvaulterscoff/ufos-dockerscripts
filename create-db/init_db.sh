#!/bin/bash
#psql --username postgres  "CREATE DATABASE ufos ; create user ufos with password 'Oracle33'; grant all privileges on database ufos to ufos;"
if [ -f /tmp/create.sql ];
then
 echo "initing empty schema"
 psql --username ufos -d ufos -f /tmp/create.sql
 rm /tmp/create.sql
fi