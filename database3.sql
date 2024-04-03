-- SQL skript pro IDS projekt c.3 (2023/2024)
-- Autor: xbarta51
-- Autor: xbabia01

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
); -- zkontrolovat, jestli se potřeba nechat středník i tady nebo ne


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
VALUES (123456789, 'Bezny', 3500, TO_DATE('1972-07-30', 'yyyy/mm/dd'), 0, 1, 1, 1);
INSERT INTO "Ucet" ("Cislo_Uctu", "Typ", "Zustatek", "Datum_zalozeni", "Aktivni", "Urok", "ID_Klienta")
VALUES (123456783, 'Sporici', 400000, TO_DATE('2010-07-30', 'yyyy/mm/dd'), 1, 1, 2);
INSERT INTO "Ucet" ("Cislo_Uctu", "Typ", "Zustatek", "Datum_zalozeni", "Aktivni", "Limit_cerpani", "ID_Klienta", "ID_Disponenta")
VALUES (123456784, 'Bezny', 250000, TO_DATE('1995-07-30', 'yyyy/mm/dd'), 1, 1, 1, 3);

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

-- Select:

-- Spojeni dvou tabulek
-- Spoji vsechny ucty s sluzbou typu "Sluzba1"
SELECT * 
FROM "Ucet" 
JOIN "Sluzby" ON "Ucet"."Cislo_Uctu" = "Sluzby"."Cislo_Uctu" 
WHERE "Sluzby"."Typ_sluzby" = 'Sluzba1';

-- Spojeni dvou tabulek
-- Ziska informace o vlastnicich a jejich uctech
SELECT V."Jmeno", V."Prijmeni", U."Cislo_Uctu", U."Typ", U."Zustatek"
FROM "Vlastnik" V
JOIN "Ucet" U ON V."ID_Klienta" = U."ID_Klienta";

-- Spojeni tri tabulek
-- Spoji vsechny operace s ucty a jejich vlastniky
SELECT O."Typ", O."Castka", O."Datum", V."Jmeno" AS Vlastnik_Jmeno, Z."Jmeno" AS Zamestnanec_Jmeno
FROM "Operace" O
JOIN "Ucet" U ON O."Cislo_Uctu" = U."Cislo_Uctu"
JOIN "Vlastnik" V ON U."ID_Klienta" = V."ID_Klienta"
LEFT JOIN "Zamestnanec" Z ON O."ID_Zamestnance" = Z."ID_Zamestnance";

-- Spojeni tri tabulek
-- Vypise vsechny ucty, kde je nejaky disponent
SELECT CONCAT(V."Jmeno", V."Prijmeni") AS jmeno_vlastnika, CONCAT(D."Jmeno", D."Prijmeni") AS jmeno_disponenta, U."Cislo_Uctu", U."Typ"
FROM "Ucet" U
JOIN "Vlastnik" V ON U."ID_Klienta" = V."ID_Klienta"
JOIN "Disponent" D ON U."ID_Disponenta" = D."ID_Klienta"
WHERE "ID_Disponenta" IS NOT NULL;

-- GROUP BY a agregacni funkce COUNT
-- Ziska celkovy pocet operaci provedenych na kazdem uctu
SELECT U."Cislo_Uctu", COUNT(*) AS "Pocet_Operaci"
FROM "Operace" O
JOIN "Ucet" U ON O."Cislo_Uctu" = U."Cislo_Uctu"
GROUP BY U."Cislo_Uctu";

-- GROUP BY a agregacni funkce AVG
-- Ziska prumerny zustatek na sporicich a beznych uctech
SELECT "Typ", AVG("Zustatek") AS "Prumerny_Zustatek"
FROM "Ucet"
GROUP BY "Typ";

-- GROUP BY a agregacni funkce SUM
-- Ziska vysi celkove transakce provedene na danem uctu
SELECT U."Cislo_Uctu", SUM(O."Castka") AS celkove_transakce
FROM "Ucet" U
JOIN "Operace" O ON U."Cislo_Uctu" = O."Cislo_Uctu"
GROUP BY U."Cislo_Uctu";

-- EXISTS
-- Ziska ucty, ktere maji alespon jednu operaci s castkou vyssi nez 4500
SELECT U."Cislo_Uctu", O."Castka"
FROM "Ucet" U
JOIN "Operace" O ON U."Cislo_Uctu" = O."Cislo_Uctu"
WHERE EXISTS (
    SELECT 1
    FROM "Operace" O
    WHERE O."Cislo_Uctu" = U."Cislo_Uctu" AND O."Castka" > 4500
);

-- IN SELECT
-- Ziska vsechny unikatni disponenty, kteri jsou disponenty na uctech s operaci vyssi nez 5000
SELECT "Jmeno", "Prijmeni"
FROM "Disponent"
WHERE "ID_Klienta" IN (
    SELECT DISTINCT O."ID_Disponenta"
    FROM "Operace" O
    WHERE O."Castka" > 5000
);
