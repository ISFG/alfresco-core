#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "spisum" --dbname "spisum" <<-EOSQL

CREATE SCHEMA audit;
CREATE SCHEMA address_book;
CREATE SCHEMA system;

EOSQL