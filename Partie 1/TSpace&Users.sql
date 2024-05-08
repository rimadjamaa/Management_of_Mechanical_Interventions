/******************creation des tables spaces ************/
CREATE TABLESPACE SQL3_TBS DATAFILE 'SQL3_TBS.dbf' SIZE 100M;
CREATE TEMPORARY TABLESPACE SQL3_TempTBS TEMPFILE 'SQL3_TempTBS.dbf' SIZE 50M;
/*****************creation des utilisateurs ******************/
CREATE USER SQL3 IDENTIFIED BY psw
    DEFAULT TABLESPACE SQL3_TBS
    TEMPORARY TABLESPACE SQL3_TempTBS;
/****************affectation des previlege *************/
GRANT ALL PRIVILEGES TO SQL3;
/***********************Creation des types ******************/
create type TypeClient;
/
create type TypeMarque;
/
create type TypeModele;
/
create type TypeVehicule;
/
create type TypeInterventions;
/
create type TypeEmploye;
/
create type TypeIntervenants;
/
create type t_set_ref_TVehicules as table of ref TypeVehicule;
/
create type t_set_ref_Tmodel as table of ref TypeModele;
/
create type t_set_ref_TIntervention as table of ref TypeInterventions;
/
create type t_set_ref_TIntervenants as table of ref TypeIntervenants;
/
CREATE TYPE TypeClient AS OBJECT (
    NUMCLIENT INT,
    CIV VARCHAR(10),
    PRENOMCLIENT VARCHAR(50),
    NOMCLIENT VARCHAR(50),
    DATENAISSANCE DATE,
    ADRESSE VARCHAR(100),
    TELPROF VARCHAR(20),
    TELPRIV VARCHAR(20),
    FAX VARCHAR(20),
    CLIENT_VEHICULE  t_set_ref_TVehicules
);
/
CREATE TYPE TypeEmploye AS OBJECT (
    NUMEMPLOYE INT,
    NOMEMP VARCHAR(50),
    PRENOMEMP VARCHAR(50),
    CATEGORIE VARCHAR(20),
    SALAIRE FLOAT,
    EMPLOYE_INTERVENANTS  t_set_ref_TIntervenants
);
/
CREATE TYPE TypeMarque AS OBJECT (
    NUMMARQUE INT,
    MARQUE VARCHAR(50),
    PAYS VARCHAR(50),
    MARQUE_MODELE  t_set_ref_Tmodel
);
/
CREATE TYPE TypeModele AS OBJECT (
    NUMMODELE INT,
    MODELE VARCHAR(50),
    MODELE_VEHICULE    t_set_ref_TVehicules,
    MODELE_MARQUE          REF TypeMarque
);
/

CREATE TYPE TypeVehicule AS OBJECT (
    NUMVEHICULE INT,
    NUMIMMAT VARCHAR(20),
    ANNEE INT,
    VEHICULE_INTERVENTIONS   t_set_ref_TIntervention,
    VEHICULE_CLIENT          REF TypeClient,
    VEHICULE_MODELE          REF TypeModele
);
/

CREATE TYPE TypeInterventions AS OBJECT (
    NUMINTERVENTION INT,
    TYPEINTERVENTION VARCHAR(50),
    DATEDEBINTERV DATE,
    DATEFININTERV DATE,
    COUTINTERV FLOAT,
    INTERVENTIONS_INTERVENANTS  t_set_ref_TIntervenants,
    INTERVENTIONS_VEHICULE      REF TypeVehicule
);
/

CREATE TYPE TypeIntervenants AS OBJECT (
    NUMINTERVENANTS INTEGER,
    DATEDEBUT DATE,
    DATEFIN DATE,
    INTERVENANTS_INTERVENTIONS  REF TypeInterventions,
    INTERVENANTS_EMPLOYE        REF TypeEmploye
);
/
/*******************Creation des tables ****************/
CREATE TABLE CLIENT OF TypeClient (
    NUMCLIENT PRIMARY KEY,
    CIV CHECK (CIV IN ('M', 'Mme', 'Mlle'))
)nested table Client_Vehicule store as table_Client_Vehicule;
/
CREATE TABLE EMPLOYE OF TypeEmploye (
    NUMEMPLOYE PRIMARY KEY,
    CATEGORIE CHECK (CATEGORIE IN ('Mécanicien', 'Assistant'))
)nested table Employe_Intervenants store as table_Employe_Intervenants;
/
CREATE TABLE MARQUE OF TypeMarque(
    NUMMARQUE PRIMARY KEY
) nested table Marque_Modele store as table_Marque_Modele;
/
CREATE TABLE MODELE OF TypeModele (
    NUMMODELE PRIMARY KEY,
    FOREIGN KEY (MODELE_MARQUE ) REFERENCES MARQUE
)nested table Modele_Vehicule store as table_Modele_Vehicule;
/
CREATE TABLE VEHICULE OF TypeVehicule (
    NUMVEHICULE PRIMARY KEY,
    FOREIGN KEY (VEHICULE_CLIENT) REFERENCES CLIENT,
    FOREIGN KEY (VEHICULE_MODELE) REFERENCES MODELE
)nested table Vehicule_Interventions store as table_Vehicule_Interventions;
/
CREATE TABLE INTERVENTIONS OF TypeInterventions (
    NUMINTERVENTION PRIMARY KEY,
    FOREIGN KEY (INTERVENTIONS_VEHICULE) REFERENCES VEHICULE
)nested table Interventions_Intervenants store as table_Itions_Inants;
/
CREATE TABLE INTERVENANTS OF TypeIntervenants (
    PRIMARY KEY (NUMINTERVENANTS),
    FOREIGN KEY (INTERVENANTS_INTERVENTIONS) REFERENCES INTERVENTIONS,
    FOREIGN KEY (INTERVENANTS_EMPLOYE) REFERENCES EMPLOYE
);