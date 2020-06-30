#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "spisum" --dbname "spisum" <<-EOSQL

SET search_path to address_book;

CREATE TABLE base_register_source
(
   code text NOT NULL,
   description text,

   CONSTRAINT pk_base_register_source PRIMARY KEY (code)
);

INSERT INTO base_register_source (code) VALUES
  ('ROB'),
  ('ROS'),
  ('EO');

CREATE TABLE address
(
   id bigint NOT NULL,
   street text, 
   city text,
   zip text,
   ruian_code text,
   momc text,
   mop text,
   nuts text,
   vusc text,
   processed_at timestamp NOT NULL DEFAULT clock_timestamp(),
   processed_by text NOT NULL DEFAULT session_user::text,

   CONSTRAINT pk_address PRIMARY KEY (id)
);

CREATE SEQUENCE subject_seq;

CREATE TABLE subject
(
   -- umele ID zaznamu
   id bigint DEFAULT nextval('subject_seq'),
   -- nazev firmy, krestni jmeno
   name text NOT NULL,
   -- prostřední jmeno
   midlename text NOT NULL,
   -- prijmeni
   surname text,
   -- titul pred/za jmenem
   degree text,
   -- cele jmeno sobjektu
   full_name text NOT NULL,
   -- id základního registru
   base_register_id text,
   -- zdroj základního registru
   fk_base_register_source_code text NOT NULL,
   -- čas identifikace, pokud null tak není identifikováno
   identified_at timestamp,
   -- system vyuzity pro identifikaci
   ais_system_id text,
   -- uzivatel provadejici identifikaci
   ident_user_id text,
   -- kod vysledku identifikace
   ident_code bigint,
   -- subjektivní priznak validity pri zadavani udaju uzivatelem
   is_valid boolean NOT NULL,
   -- typ uživatele fyzická (fo), právnická (po) osoba
   subject_type text NOT NULL CHECK (subject_type in ('fo', 'po')),
   -- cas posledni aktualizace záznamu
   updated_at timestamp,
   -- trvalá adresa
   fk_permanent_address_id bigint,
   -- korespondenční adresa
   fk_correspondence_address_id bigint,
   -- cas vlozeni zaznamu do DB
   processed_at timestamp NOT NULL DEFAULT clock_timestamp(),
   -- db uzivatel vkladajici zaznam
   processed_by text NOT NULL DEFAULT session_user::text,

   CONSTRAINT pk_subject PRIMARY KEY (id),
   CONSTRAINT fk_subject_base_register_source_code FOREIGN KEY (fk_base_register_source_code)
        REFERENCES base_register_source (code),
   CONSTRAINT fk_subject_permanent_address_id FOREIGN KEY (fk_permanent_address_id)
        REFERENCES address (id),
   CONSTRAINT fk_subject_correspondence_address_id FOREIGN KEY (fk_correspondence_address_id)
        REFERENCES address (id)
);

CREATE TABLE document
(
   -- pid
   pid text NOT NULL,
   -- cislo jednaci
   cj text, 
   -- ? 
   ecse text,
   -- ? zjistím od Michala, evidence
   records text,
   -- ? zjistim od Michala, pravdìpodobnì úplnost dat 
   is_valid boolean,
   --  cas vlozeni záznamu do DB
   processed_at timestamp NOT NULL DEFAULT clock_timestamp(),
    -- db uzivatel vkladajici zaznam
   processed_by text NOT NULL DEFAULT session_user::text,

   CONSTRAINT pk_document PRIMARY KEY (pid)
);

CREATE SEQUENCE subject_placement_seq;

CREATE TABLE document_subject_placement
(
   -- umele ID zaznamu
   id bigint NOT NULL DEFAULT nextval('subject_placement_seq'),
   fk_subject_id bigint NOT NULL,
   fk_document_pid text NOT NULL,
    -- cas vlozeni zaznamu do DB
   processed_at timestamp NOT NULL DEFAULT clock_timestamp(),
    -- db uzivatel vkladajici zaznam
   processed_by text NOT NULL DEFAULT session_user::text,

   CONSTRAINT pk_document_subject_placement PRIMARY KEY (id),
   CONSTRAINT fk_document_subject_placement_subject_id FOREIGN KEY (fk_subject_id)
      REFERENCES subject (id),
   CONSTRAINT fk_document_subject_placement_document_pid FOREIGN KEY (fk_document_pid)
      REFERENCES document (pid)
);
        
SET search_path TO DEFAULT;

EOSQL

