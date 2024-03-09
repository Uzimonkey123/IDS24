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
    "Jmeno" VARCHAR(50) NOT NULL,
    "Prijmeni" VARCHAR(50),
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
    "Prijmeni" CHAR(50),
    "Datum_narozeni" DATE NOT NULL,
    "Telefonni_cislo" VARCHAR(14) NOT NULL,
    "Email" VARCHAR(50) NOT NULL,
    "Adresa" VARCHAR(100) NOT NULL
);

CREATE TABLE "Ucet" (
    "Cislo_Uctu" VARCHAR(34) PRIMARY KEY NOT NULL,
    "Typ" VARCHAR(50) NOT NULL,
    "Zustatek" DECIMAL(10,2) NOT NULL,
    "Datum_zalozeni" DATE NOT NULL,
    "Aktivni" INTEGER NOT NULL,
    -- Diskriminatory (specializace)
    "Urok" DECIMAL(10,2) DEFAULT NULL, -- Sporitelni
    "Limit_cerpani" DECIMAL(10,2) DEFAULT NULL, -- Bezny
    "ID_Klienta" INTEGER NOT NULL,
    "ID_Disponenta" INTEGER DEFAULT NULL,

    -- Foreign Keys
    CONSTRAINT "FK_Ucet_Vlastnik" FOREIGN KEY ("ID_Klienta") REFERENCES "Vlastnik"("ID_Klienta"),
    CONSTRAINT "FK_Ucet_Disponent" FOREIGN KEY ("ID_Disponenta") REFERENCES "Disponent"("ID_Klienta")
);

CREATE TABLE "Operace" (
    "ID_Operace" INTEGER GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "Typ" VARCHAR(50) NOT NULL,
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
    "Typ_sluzby" VARCHAR(50) NOT NULL,
    "Cislo_Uctu" VARCHAR(34) NOT NULL,

    -- Foreign keys
    CONSTRAINT "FK_Sluzby_Ucet" FOREIGN KEY ("Cislo_Uctu") REFERENCES "Ucet"("Cislo_Uctu")    
);

CREATE TABLE "Prava" (
    "ID_Prava" INTEGER GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "Typ_omezeni" VARCHAR(50) NOT NULL,
    "Cislo_Uctu" VARCHAR(34) DEFAULT NULL,
    "ID_Disponenta" INTEGER DEFAULT NULL,
    "ID_Klienta" INTEGER NOT NULL,

    -- Foreign keys
    CONSTRAINT "FK_Prava_Ucet" FOREIGN KEY ("Cislo_Uctu") REFERENCES "Ucet"("Cislo_Uctu"),
    CONSTRAINT "FK_Prava_Disponent" FOREIGN KEY ("ID_Disponenta") REFERENCES "Disponent"("ID_Klienta"),
    CONSTRAINT "FK_Prava_Vlastnik "FOREIGN KEY ("ID_Klienta") REFERENCES "Vlastnik"("ID_Klienta")
);

-- Test inputs:
INSERT INTO "Zamestnanec" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa")
VALUES ('123456/7890', 'Zamestnanec1', 'Testovaci', TO_DATE('1972-07-30', 'yyyy/mm/dd'), '123456789', 'zamestnanec@fit.vut', 'Brno');

INSERT INTO "Vlastnik" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa") 
VALUES ('123456/7890', 'Vlastnik1', 'Testovaci', TO_DATE('1972-07-30', 'yyyy/mm/dd'), '123456789', 'asder@fit.vut', 'Brno');

INSERT INTO "Disponent" ("Rodne_cislo", "Jmeno", "Prijmeni", "Datum_narozeni", "Telefonni_cislo", "Email", "Adresa")
VALUES ('123456/7890', 'Disponent1', 'Testovaci', TO_DATE('1972-07-30', 'yyyy/mm/dd'), '123456789', 'disponent@vut.fit', 'Brno');

INSERT INTO "Ucet" ("Cislo_Uctu", "Typ", "Zustatek", "Datum_zalozeni", "Aktivni", "Limit_cerpani", "ID_Klienta", "ID_Disponenta")
VALUES (123456789, 'Bezny', 1000, TO_DATE('1972-07-30', 'yyyy/mm/dd'), 0, 1, 1, 1);

INSERT INTO "Operace" ("Typ", "Castka", "Datum", "Cislo_Uctu", "ID_Zamestnance", "ID_Disponenta", "ID_Klienta")
VALUES ('Vklad', 1000, TO_DATE('1972-07-30', 'yyyy/mm/dd'), 123456789, 1, 1, 1);

INSERT INTO "Sluzby" ("Typ_sluzby", "Cislo_Uctu")
VALUES ('Sluzba1', 123456789);

INSERT INTO "Prava" ("Typ_omezeni", "Cislo_Uctu", "ID_Disponenta", "ID_Klienta")
VALUES ('Omezeni1', 123456789, 1, 1);