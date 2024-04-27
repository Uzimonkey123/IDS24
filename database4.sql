-- SQL skript pro IDS projekt c.4 (2023/2024)
-- Autor: xbarta51
-- Autor: xbabia01

DROP TABLE "Log";
DROP TABLE "Prava_Disponent";
DROP TABLE "Prava";
DROP TABLE "Sluzby";
DROP TABLE "Operace";
DROP TABLE "Ucet";
DROP TABLE "Disponent";
DROP TABLE "Vlastnik";
DROP TABLE "Zamestnanec";

CREATE TABLE "Zamestnanec" (
    "ID_Zamestnance" INTEGER GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "Rodne_cislo" VARCHAR(11) NOT NULL CHECK(REGEXP_LIKE("Rodne_cislo", '^[0-9]{6}/[0-9]{4}$')),
    "Jmeno" CHAR(50) NOT NULL,
    "Prijmeni" CHAR(50) NOT NULL,
    "Datum_narozeni" DATE NOT NULL,
    "Telefonni_cislo" VARCHAR(14) NOT NULL,
    "Email" VARCHAR(50) NOT NULL,
    "Adresa" VARCHAR(100) NOT NULL
);

CREATE TABLE "Vlastnik" (
    "ID_Klienta" INTEGER GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "Rodne_cislo" VARCHAR(11) NOT NULL CHECK(REGEXP_LIKE("Rodne_cislo", '^[0-9]{6}/[0-9]{4}$')),
    "Jmeno" CHAR(50) NOT NULL,
    "Prijmeni" CHAR(50) NOT NULL,
    "Datum_narozeni" DATE NOT NULL,
    "Telefonni_cislo" VARCHAR(14) NOT NULL,
    "Email" VARCHAR(50) NOT NULL,
    "Adresa" VARCHAR(100) NOT NULL
);

CREATE TABLE "Disponent" (
    "ID_Klienta" INTEGER GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "Rodne_cislo" VARCHAR(11) NOT NULL CHECK(REGEXP_LIKE("Rodne_cislo", '^[0-9]{6}/[0-9]{4}$')),
    "Jmeno" CHAR(50) NOT NULL,
    "Prijmeni" CHAR(50) NOT NULL,
    "Datum_narozeni" DATE NOT NULL,
    "Telefonni_cislo" VARCHAR(14) NOT NULL,
    "Email" VARCHAR(50) NOT NULL,
    "Adresa" VARCHAR(100) NOT NULL
);

CREATE TABLE "Ucet" (
    "Cislo_Uctu" VARCHAR(34) PRIMARY KEY NOT NULL,
    "Typ" CHAR(50) NOT NULL CHECK(REGEXP_LIKE("Typ", '^(Bezny|Sporici)')),
    "Zustatek" DECIMAL(10,2) NOT NULL,
    "Datum_zalozeni" DATE NOT NULL,
    "Aktivni" INTEGER NOT NULL,
    -- Diskriminatory (specializace)
    -- V pripade ze ucet je typu sporici, bude urok null, a naopak
    "Urok" DECIMAL(10,2) DEFAULT NULL, -- Sporici
    "Limit_cerpani" DECIMAL(10,2) DEFAULT NULL, -- Bezny
    "ID_Klienta" INTEGER NOT NULL,
    "ID_Disponenta" INTEGER DEFAULT NULL,

    -- Foreign Keys
    CONSTRAINT "FK_Ucet_Vlastnik" FOREIGN KEY ("ID_Klienta") REFERENCES "Vlastnik"("ID_Klienta"),
    CONSTRAINT "FK_Ucet_Disponent" FOREIGN KEY ("ID_Disponenta") REFERENCES "Disponent"("ID_Klienta")
);

CREATE TABLE "Operace" (
    "ID_Operace" INTEGER GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "Typ" CHAR(50) NOT NULL,
    "Castka" DECIMAL(10,2) NOT NULL,
    "Datum" DATE NOT NULL,
    "Cislo_Uctu" VARCHAR(34) NOT NULL,
    "ID_Zamestnance" INTEGER DEFAULT NULL,
    "ID_Disponenta" INTEGER DEFAULT NULL,
    "ID_Klienta" INTEGER NOT NULL, -- autorizace operace

    -- Foreign keys
    CONSTRAINT "FK_Operace_Ucet" FOREIGN KEY ("Cislo_Uctu") REFERENCES "Ucet"("Cislo_Uctu"),
    CONSTRAINT "FK_Operace_Zamestnanec" FOREIGN KEY ("ID_Zamestnance") REFERENCES "Zamestnanec"("ID_Zamestnance"),
    CONSTRAINT "FK_Operace_Disponent" FOREIGN KEY ("ID_Disponenta") REFERENCES "Disponent"("ID_Klienta"),
    CONSTRAINT "FK_Operace_Vlastnik" FOREIGN KEY ("ID_Klienta") REFERENCES "Vlastnik"("ID_Klienta")
);

CREATE TABLE "Sluzby" (
    "ID_Sluzby" INTEGER GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "Typ_sluzby" CHAR(50) NOT NULL,
    "Cislo_Uctu" VARCHAR(34) NOT NULL,
    "ID_Zamestnance" INTEGER NOT NULL,

    -- Foreign keys
    CONSTRAINT "FK_Sluzby_Ucet" FOREIGN KEY ("Cislo_Uctu") REFERENCES "Ucet"("Cislo_Uctu"),
    CONSTRAINT "FK_Sluzby_Zamestnanec" FOREIGN KEY ("ID_Zamestnance") REFERENCES "Zamestnanec"("ID_Zamestnance")
);

CREATE TABLE "Prava" (
    "ID_Prava" INTEGER GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "Typ_omezeni" CHAR(50) NOT NULL,
    "Cislo_Uctu" VARCHAR(34) DEFAULT NULL,
    "ID_Disponenta" INTEGER NOT NULL,
    "ID_Klienta" INTEGER NOT NULL,

    -- Foreign keys
    CONSTRAINT "FK_Prava_Ucet" FOREIGN KEY ("Cislo_Uctu") REFERENCES "Ucet"("Cislo_Uctu"),
    CONSTRAINT "FK_Prava_Disponent" FOREIGN KEY ("ID_Disponenta") REFERENCES "Disponent"("ID_Klienta"),
    CONSTRAINT "FK_Prava_Vlastnik "FOREIGN KEY ("ID_Klienta") REFERENCES "Vlastnik"("ID_Klienta")
);

CREATE TABLE "Prava_Disponent" ( -- pomocna tabulka pro N:M
    "ID_Prava" INTEGER NOT NULL,
    "ID_Disponent" INTEGER NOT NULL,

    CONSTRAINT "PK_Prava_Disponent" PRIMARY KEY ("ID_Prava", "ID_Disponent"),
    CONSTRAINT "FK_Prava_Disponent_Prava" FOREIGN KEY ("ID_Prava") REFERENCES "Prava"("ID_Prava"),
    CONSTRAINT "FK_Prava_Disponent_Disponent" FOREIGN KEY ("ID_Disponent") REFERENCES "Disponent"("ID_Klienta")
);

CREATE TABLE "Log" (
    "Cislo_Uctu" VARCHAR2(34),
    "Zustatek" DECIMAL,
    "ID_Klienta" INTEGER
);

-- Cast 4
-- Trigger 1
CREATE OR REPLACE TRIGGER aktualizace_zustatku
AFTER INSERT ON "Operace"
FOR EACH ROW
BEGIN
    IF :NEW."Typ" = 'Vklad' THEN
        UPDATE "Ucet" SET "Zustatek" = "Zustatek" + :NEW."Castka"
        WHERE "Cislo_Uctu" = :NEW."Cislo_Uctu";
    ELSIF :NEW."Typ" = 'Vyber' THEN
        UPDATE "Ucet" SET "Zustatek" = "Zustatek" - :NEW."Castka"
        WHERE "Cislo_Uctu" = :NEW."Cislo_Uctu";
    END IF;
END;

-- Predvedeni triggeru
-- Ucet 123456789 po vsech operacich by mel mit zustatek 7500
SELECT "Zustatek" FROM "Ucet" WHERE "Cislo_Uctu" = '123456789';
-- Ucet 123456783 po vsech operacich by mel mit zustatek po 4x vyberech (kazdy vyber byl 10000) 360000
SELECT "Zustatek" FROM "Ucet" WHERE "Cislo_Uctu" = '123456783';

-- Trigger 2
CREATE OR REPLACE TRIGGER aktualizace_aktivity
BEFORE INSERT ON "Ucet"
FOR EACH ROW
BEGIN
    IF :NEW."Datum_zalozeni" <= ADD_MONTHS(SYSDATE, -60) THEN
        :NEW."Aktivni" := 0;
    ELSE
        :NEW."Aktivni" := 1;
    END IF;
END;

-- Predvedeni triggeru
-- Ucet 123456789 by mel byt neaktivni, protoze byl zalozen pred vice nez 5 lety (neaktivni -> Aktivni = 0)
SELECT "Aktivni" FROM "Ucet" WHERE "Cislo_Uctu" = '123456789';

-- Test inputs:
INSERT INTO "Zamestnanec" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa")
VALUES ('123456/7890', 'Zamestnanec1', 'Testovaci1', TO_DATE('1972-07-30', 'yyyy/mm/dd'), '123456789', 'zamestnanec1@fit.vut', 'Brno');
INSERT INTO "Zamestnanec" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa")
VALUES ('123456/7891', 'Zamestnanec2', 'Testovaci2', TO_DATE('1945-07-30', 'yyyy/mm/dd'), '123456780', 'zamestnanec2@fit.vut', 'Brno');
INSERT INTO "Zamestnanec" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa")
VALUES ('123456/7892', 'Zamestnanec3', 'Testovaci3', TO_DATE('2003-05-20', 'yyyy/mm/dd'), '203456780', 'zamestnanec3@fit.vut', 'Brno');

INSERT INTO "Vlastnik" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa") 
VALUES ('123456/7895', 'Vlastnik1', 'Testovaci1', TO_DATE('2001-02-15', 'yyyy/mm/dd'), '123456789', 'asder1@fit.vut', 'Brno');
INSERT INTO "Vlastnik" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa") 
VALUES ('123456/7893', 'Vlastnik2', 'Testovaci2', TO_DATE('2002-07-25', 'yyyy/mm/dd'), '123456780', 'asder2@fit.vut', 'Brno');
INSERT INTO "Vlastnik" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa") 
VALUES ('123456/7894', 'Vlastnik3', 'Testovaci3', TO_DATE('1972-07-30', 'yyyy/mm/dd'), '123456781', 'asder3@fit.vut', 'Brno');

INSERT INTO "Disponent" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa")
VALUES ('123456/7898', 'Disponent1', 'Testovaci1', TO_DATE('1980-05-01', 'yyyy/mm/dd'), '123456789', 'disponent1@vut.fit', 'Brno');
INSERT INTO "Disponent" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa")
VALUES ('123456/7896', 'Disponent2', 'Testovaci2', TO_DATE('1981-05-02', 'yyyy/mm/dd'), '123456785', 'disponent2@vut.fit', 'Brno');
INSERT INTO "Disponent" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa")
VALUES ('123456/7897', 'Disponent3', 'Testovaci3', TO_DATE('1982-05-03', 'yyyy/mm/dd'), '123456786', 'disponent3@vut.fit', 'Brno');

INSERT INTO "Ucet" ("Cislo_Uctu", "Typ", "Zustatek", "Datum_zalozeni", "Aktivni", "Limit_cerpani", "ID_Klienta", "ID_Disponenta")
VALUES (123456789, 'Bezny', 3500, TO_DATE('1972-07-30', 'yyyy/mm/dd'), 1, 1, 1, 1);
INSERT INTO "Ucet" ("Cislo_Uctu", "Typ", "Zustatek", "Datum_zalozeni", "Aktivni", "Urok", "ID_Klienta")
VALUES (123456783, 'Sporici', 400000, TO_DATE('2023-07-30', 'yyyy/mm/dd'), 1, 1, 2);
INSERT INTO "Ucet" ("Cislo_Uctu", "Typ", "Zustatek", "Datum_zalozeni", "Aktivni", "Limit_cerpani", "ID_Klienta", "ID_Disponenta")
VALUES (123456784, 'Bezny', 250000, TO_DATE('2019-07-30', 'yyyy/mm/dd'), 1, 1, 1, 3);

INSERT INTO "Operace" ("Typ", "Castka", "Datum", "Cislo_Uctu", "ID_Zamestnance", "ID_Disponenta", "ID_Klienta")
VALUES ('Vklad', 4000, TO_DATE('1972-07-30', 'yyyy/mm/dd'), 123456789, 1, 3, 3);
INSERT INTO "Operace" ("Typ", "Castka", "Datum", "Cislo_Uctu", "ID_Zamestnance", "ID_Klienta")
VALUES ('Vyber', 10000, TO_DATE('1990-07-30', 'yyyy/mm/dd'), 123456783, 1, 2);
INSERT INTO "Operace" ("Typ", "Castka", "Datum", "Cislo_Uctu", "ID_Klienta")
VALUES ('Transakce', 15000, TO_DATE('2003-07-30', 'yyyy/mm/dd'), 123456784, 1);
INSERT INTO "Operace" ("Typ", "Castka", "Datum", "Cislo_Uctu", "ID_Klienta")
VALUES ('Transakce', 15000, TO_DATE('2003-07-31', 'yyyy/mm/dd'), 123456784, 1);
INSERT INTO "Operace" ("Typ", "Castka", "Datum", "Cislo_Uctu", "ID_Zamestnance", "ID_Disponenta", "ID_Klienta")
VALUES ('Vyber', 10000, TO_DATE('1990-07-30', 'yyyy/mm/dd'), 123456783, 1, 3, 2);
INSERT INTO "Operace" ("Typ", "Castka", "Datum", "Cislo_Uctu", "ID_Zamestnance", "ID_Disponenta", "ID_Klienta")
VALUES ('Vyber', 10000, TO_DATE('1990-07-30', 'yyyy/mm/dd'), 123456783, 1, 2, 2);
INSERT INTO "Operace" ("Typ", "Castka", "Datum", "Cislo_Uctu", "ID_Zamestnance", "ID_Disponenta", "ID_Klienta")
VALUES ('Vyber', 10000, TO_DATE('1990-07-30', 'yyyy/mm/dd'), 123456783, 1, 2, 2);

INSERT INTO "Sluzby" ("Typ_sluzby", "Cislo_Uctu", "ID_Zamestnance")
VALUES ('Sluzba1', 123456789, 1);
INSERT INTO "Sluzby" ("Typ_sluzby", "Cislo_Uctu", "ID_Zamestnance")
VALUES ('Sluzba2', 123456783, 2);
INSERT INTO "Sluzby" ("Typ_sluzby", "Cislo_Uctu", "ID_Zamestnance")
VALUES ('Sluzba3', 123456783, 3);

INSERT INTO "Prava" ("Typ_omezeni", "Cislo_Uctu", "ID_Disponenta", "ID_Klienta")
VALUES ('Omezeni1', 123456789, 1, 2);
INSERT INTO "Prava" ("Typ_omezeni", "ID_Disponenta", "ID_Klienta")
VALUES ('Omezeni2', 3, 1);
INSERT INTO "Prava" ("Typ_omezeni", "Cislo_Uctu", "ID_Disponenta", "ID_Klienta")
VALUES ('Omezeni3', 123456783, 2, 1);

INSERT INTO "Prava_Disponent" ("ID_Prava", "ID_Disponent")
VALUES (1, 1);
INSERT INTO "Prava_Disponent" ("ID_Prava", "ID_Disponent")
VALUES (1, 3);
INSERT INTO "Prava_Disponent" ("ID_Prava", "ID_Disponent")
VALUES (1, 2);

-- Proccedura 1
-- Procedura pro pridani uctu do tabulky ucet, pokud se nepodari, vyhodi vyjimku
CREATE OR REPLACE PROCEDURE pridat_ucet(p_cislo_uctu IN "Ucet"."Cislo_Uctu"%TYPE,
                                        p_typ IN "Ucet"."Typ"%TYPE,
                                        p_zustatek IN "Ucet"."Zustatek"%TYPE,
                                        p_datum_zalozeni IN "Ucet"."Datum_zalozeni"%TYPE,
                                        p_aktivni IN "Ucet"."Aktivni"%TYPE,
                                        p_id_klienta IN "Ucet"."ID_Klienta"%TYPE)
IS
BEGIN
    INSERT INTO "Ucet" ("Cislo_Uctu", "Typ", "Zustatek", "Datum_zalozeni", "Aktivni", "ID_Klienta")
    VALUES (p_cislo_uctu, p_typ, p_zustatek, p_datum_zalozeni, p_aktivni, p_id_klienta);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Chyba pridani uctu k databazi: ' || SQLERRM);
END;

-- Procedura 2
-- Prida vsechny ucty, ktere maji negativni zustatek do TABULKY Log
CREATE OR REPLACE PROCEDURE seznam_zadluzenych_uctu
IS
    CURSOR zadluzene_ucty IS
        SELECT "Cislo_Uctu", "Zustatek", "ID_Klienta"
        FROM "Ucet"
        WHERE "Zustatek" < 0;
    n_ucet zadluzene_ucty%ROWTYPE;
BEGIN
    OPEN zadluzene_ucty;
    LOOP
        FETCH zadluzene_ucty INTO n_ucet;
        EXIT WHEN zadluzene_ucty%NOTFOUND;
        -- Pridani uctu do tabulky Log misto vypisu
        INSERT INTO "Log" ("Cislo_Uctu", "Zustatek", "ID_Klienta")
        VALUES (n_ucet."Cislo_Uctu", n_ucet."Zustatek", n_ucet."ID_Klienta");
    END LOOP;
    CLOSE zadluzene_ucty;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Chyba pri ziskani zadluzenych uctu: ' || SQLERRM);
END;

-- Predvedeni procedur
-- Kdyz vlozime duplicitni cislo uctu nebo napriklad neexistujici ID_klienta, tak vyhodi vyjimku
BEGIN
    pridat_ucet('1234567890', 'Bezny', -1000, TO_DATE('2024-04-21', 'yyyy/mm/dd'), 1, 1);
END;

-- 
BEGIN
    seznam_zadluzenych_uctu;
END;

-- Pro zobrazeni uctu, ktere maji negativni zustatek
SELECT * FROM "Log";


-- EXPLAIN PLAN: 
EXPLAIN PLAN FOR
SELECT O."Cislo_Uctu", U."Typ", SUM(O."Castka") AS Celkove_transakce
FROM "Operace" O
JOIN "Ucet" U ON O."Cislo_Uctu" = U."Cislo_Uctu"
WHERE O."Cislo_Uctu" = '123456789'
GROUP BY O."Cislo_Uctu", U."Typ";

-- Zobrazeni pred indexem
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Vytvoreni indexu pro optimalizaci explain plan (celkova_transakce)
CREATE INDEX idx_cislo_uctu ON "Operace" ("Cislo_Uctu");

-- Po vytvoreni indexu se jiz nepristupuje k cele tabulce (TABLE ACCESS FULL), ale jen se hleda v rozsahu indexu (INDEX RANGE SCAN)
EXPLAIN PLAN FOR
SELECT O."Cislo_Uctu", U."Typ", SUM(O."Castka") AS Celkove_transakce
FROM "Operace" O
JOIN "Ucet" U ON O."Cislo_Uctu" = U."Cislo_Uctu"
WHERE O."Cislo_Uctu" = '123456789'
GROUP BY O."Cislo_Uctu", U."Typ";

-- Zobrazeni po indexu
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Komplexni SELECT s vyuzitim CASE a WITH
-- Ziskava aktivitu na danem uctu podle vyse transakci
WITH aktivita_uctu AS (
    SELECT "Cislo_Uctu", SUM("Castka") AS celkove_transakce
    FROM "Operace"
    GROUP BY "Cislo_Uctu"
)
SELECT "Cislo_Uctu",
       CASE
           WHEN celkove_transakce > 8000 THEN 'High'
           WHEN celkove_transakce BETWEEN 8000 AND 4000 THEN 'Medium'
           ELSE 'Low'
       END AS Aktivita
FROM aktivita_uctu;

-- -------------------------------------------------
-- Materializovany pohled patrici druhemu clenu tymu

CREATE MATERIALIZED VIEW "Prehled_uctu"
AS
SELECT v."Jmeno", v."Prijmeni", v."Email", SUM(u."Zustatek") AS total_balance
FROM "Vlastnik" v
JOIN "Ucet" u ON v."ID_Klienta" = u."ID_Klienta"
GROUP BY v."Jmeno", v."Prijmeni", v."Email";

SELECT * FROM "Prehled_uctu";

-- --------------------------------------------------

-- Prava pro uzivatele

GRANT ALL ON "Log" TO xbarta51;
GRANT ALL ON "Prava_Disponent" TO xbarta51;
GRANT ALL ON "Prava" TO xbarta51;
GRANT ALL ON "Sluzby" TO xbarta51;
GRANT ALL ON "Operace" TO xbarta51;
GRANT ALL ON "Ucet" TO xbarta51;
GRANT ALL ON "Disponent" TO xbarta51;
GRANT ALL ON "Vlastnik" TO xbarta51;
GRANT ALL ON "Zamestnanec" TO xbarta51;

GRANT EXECUTE ON pridat_ucet TO xbarta51;
GRANT EXECUTE ON seznam_zadluzenych_uctu TO xbarta51;