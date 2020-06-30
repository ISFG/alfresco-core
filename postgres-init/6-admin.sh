#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "spisum" --dbname "spisum" <<-EOSQL

SET search_path to system;

CREATE TABLE system_login
(
    username text,
    password text,

    CONSTRAINT pk_system_login PRIMARY KEY (username)
);

SET search_path TO DEFAULT;

EOSQL