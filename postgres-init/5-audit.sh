#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "spisum" --dbname "spisum" <<-EOSQL

SET search_path to audit;

CREATE TABLE event_type
(
    code text,
    description text,

  CONSTRAINT pk_event_type PRIMARY KEY (code)
);

INSERT INTO event_type (code) VALUES
  ('Zalozeni'),
  ('Uprava'),
  ('Zruseni'),
  ('Zobrazeni'),
  ('Export'),
  ('Prenos'),
  ('Storno'),
  ('Zniceni'),
  ('VlozeniDoSpisu'),
  ('VyjmutiZeSpisu'),
  ('PripojeniCJ'),
  ('NovaVerze'),
  ('VlozeniKDokumentu'),
  ('VyjmutiZDokumentu'),
  ('VlozeniKVypraveni'),
  ('VyjmutiZVypraveni'),
  ('PripojeniPodpisu'),
  ('PripojeniRazitka'),
  ('FinalniVerze'),
  ('PredaniVypravne'),
  ('Vypraveno'),
  ('Doruceno'),
  ('Vyrizeni'),
  ('Schvaleni'),
  ('Uzavreni'),
  ('Otevreni'),
  ('PostoupeniAgende'),
  ('VraceniZAgendy'),
  ('ZmenaZpracovatele'),
  ('PripojeniKlicovehoSlova'),
  ('OdebraniKlicovehoSlova'),
  ('PredaniNaSpisovnu'),
  ('PrevzetiNaSpisovnu'),
  ('VraceniZeSpisovny'),
  ('PozastaveniSkartacniOperace'),
  ('ZruseniPozastaveniSkartacniOperace'),
  ('VlozeniDoUkladaciJednotky'),
  ('VyjmutiZUkladaciJednotky'),
  ('VlozeniDoSkartacnihoNavrhu'),
  ('VyjmutiZeSkartacnihoNavrhu'),
  ('VlozeniDoSpisoveRozluky'),
  ('VyjmutiZeSpisoveRozluky'),
  ('KonverzeZMociUredni'),
  ('KonverzeFormatu')
;

CREATE TABLE node_type
(
    code text,
    description text,
    
    CONSTRAINT pk_node_type PRIMARY KEY (code)
);

INSERT INTO node_type (code) VALUES
  ('Komponenta'),
  ('Zasilka'),
  ('Dokument'),
  ('Spis'),
  ('Soucast'),
  ('Dil'),
  ('TypovySpis'),
  ('VecnaSkupina'),
  ('SpisovyPlan'),
  ('Denik'),
  ('KonfiguraceSystemu'),
  ('Osoba'),
  ('FunkcniMisto'),
  ('SpisovyUzel'),
  ('OrganizacniJednotka'),
  ('SkupinaUzivatelu'),
  ('KonverzeZMociUredni'),
  ('Obalka'),
  ('SkartacniRezim'),
  ('SkartacniNavrh'),
  ('SpisovaRozluka'),
  ('SablonaTypovehoSpisu'),
  ('SablonaSoucasti'),
  ('Subjekt'),
  ('TypDokumentu'),
  ('TypSpisu'),
  ('UkladaciJednotka'),
  ('SchvaleniSpis'),
  ('SchvaleniDokument'),
  ('SchvaleniKomponenta'),
  ('ZpusobVyrizeni')
;

CREATE SEQUENCE transaction_history_seq;

CREATE TABLE transaction_history
(
    -- umělé ID záznamu
    id bigint DEFAULT nextval('transaction_history_seq'),
    -- Alfresco unique object id
    node_id text NOT NULL,
    -- Alfresco node type
    ssl_node_type text NOT NULL,
    -- PID 
    pid text NOT NULL,
    -- Alfresco node/object type
    fk_node_type_code text NOT NULL,
    -- Datum a cas vzniku události, co časová zona?
    occured_at timestamp NOT NULL,
    -- Autor změny
    user_id text NOT NULL,
    -- usergroup id
    user_group_id text NOT NULL,
    -- Typ událostí, která nastala
    fk_event_type_code text NOT NULL,
    -- parametry události
    event_parameters jsonb,
    -- parametry události
    event_source text NOT null,
    -- hash záznamu
    row_hash text NOT NULL,
    -- čas vlozeni záznamu do DB
    processed_at timestamp NOT NULL DEFAULT clock_timestamp(),
    -- databázový uživatel, který vložil záznam
    processed_by text NOT NULL DEFAULT session_user::text,


    CONSTRAINT pk_transaction_history PRIMARY KEY (id),
    CONSTRAINT fk_transaction_history_event_type_code FOREIGN KEY (fk_event_type_code)
        REFERENCES event_type (code),
    CONSTRAINT fk_transaction_history_node_type_code FOREIGN KEY (fk_node_type_code)
        REFERENCES node_type (code)
);

CREATE INDEX ix_transaction_history_fk_event_type_code ON transaction_history (fk_event_type_code);
CREATE INDEX ix_transaction_history_fk_node_type_code ON transaction_history (fk_node_type_code);
CREATE INDEX ix_transaction_history_node_id ON transaction_history (node_id);
CREATE INDEX ix_transaction_history_fk_object_type_code ON transaction_history (fk_node_type_code);

CREATE OR REPLACE FUNCTION hash_record() RETURNS trigger AS \$body\$ 
BEGIN
  IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
    RAISE EXCEPTION '%', format('Opperation %1\$L on table %2\$L is not permited!', TG_OP, TG_TABLE_NAME);
  END IF;
  NEW.row_hash := encode(sha256(NEW::text::bytea), 'hex');
  RETURN NEW;
END;
\$body\$ LANGUAGE plpgsql;

CREATE TRIGGER hash_record_trg 
    BEFORE INSERT OR UPDATE OR DELETE ON transaction_history
    FOR EACH ROW EXECUTE PROCEDURE hash_record();
 
SET search_path TO DEFAULT;
   
EOSQL

