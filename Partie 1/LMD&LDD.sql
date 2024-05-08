/*************Les methodes ***********/
-- Methode 1:Calculer pour chaque employé, le nombre des interventions effectuées.

--  signateur 
ALTER TYPE TypeEmploye ADD MEMBER FUNCTION nombreInterventions RETURN NUMBER cascade;
-- corp
CREATE OR REPLACE TYPE BODY TypeEmploye AS
  MEMBER FUNCTION nombreInterventions RETURN NUMBER IS
    totalInterventions NUMBER := 0;
  BEGIN
    totalInterventions := CARDINALITY(self.EMPLOYE_INTERVENANTS);
    RETURN totalInterventions;
  END;
END;
/
-- exemple d'excution :
SELECT e.numemploye AS NumEmploye, e.nombreInterventions() AS NombreInterventions 
    FROM employe e 
    ORDER BY NombreInterventions DESC;


-- Methode 2 :Calculer pour chaque marque, le nombre de modèles.
--  signateur 
ALTER TYPE TypeMarque ADD MEMBER FUNCTION nombreModeles RETURN NUMBER cascade;
-- corp
CREATE OR REPLACE TYPE BODY TypeMarque AS
  MEMBER FUNCTION nombreModeles RETURN NUMBER IS
    totalModeles NUMBER := 0;
  BEGIN
    totalModeles := CARDINALITY(self.MARQUE_MODELE);
    RETURN totalModeles;
  END;
END;
/
-- exemple d'excution :
SELECT m.nummarque AS NumMarque, m.nombreModeles() AS NombreModeles 
    FROM marque m 
    ORDER BY NombreModeles DESC;

-- Methode 3 :Calculer pour chaque modèle, le nombre de véhicules.
--  signateur 
ALTER TYPE TypeModele ADD MEMBER FUNCTION nombreVehicules RETURN NUMBER cascade;
-- corp
CREATE OR REPLACE TYPE BODY TypeModele AS
  MEMBER FUNCTION nombreVehicules RETURN NUMBER IS
    totalVehicule NUMBER := 0;
  BEGIN
    totalVehicule := CARDINALITY(self.MODELE_VEHICULE);
    RETURN totalVehicule;
  END;
END;
/
-- exemple d'excution :
SELECT m.nummodele AS NumModele, m.nombreVehicules() AS NombreVehicules 
    FROM modele m 
    ORDER BY NombreVehicules DESC;

-- Methode 4:Lister pour chaque client, ses véhicules.
CREATE type vehicules_list as table of Typevehicule;
--  signateur 
alter type typeclient drop MEMBER FUNCTION LISTER_VEHICULES RETURN T_SET_REF_TVEHICULES cascade;
alter type typeclient add  MEMBER FUNCTION lister_vehicules RETURN vehicules_list cascade;
-- body
CREATE OR REPLACE TYPE BODY typeclient AS
 MEMBER FUNCTION lister_vehicules RETURN vehicules_list IS
    vehicules_lis vehicules_list;
 BEGIN
      Select CAST(MULTISET(select deref(value(o)) from table(self.CLIENT_VEHICULE) o )as vehicules_list )
      into vehicules_lis
      from dual;
 RETURN vehicules_lis;
 END;
END;
/
-- execution 
DECLARE
    client_obj TypeClient;
    vehicules_li vehicules_list;
BEGIN
    FOR client_rec IN (SELECT * FROM CLIENT) LOOP
        client_obj := TypeClient(client_rec.NUMCLIENT, client_rec.CIV, client_rec.PRENOMCLIENT, client_rec.NOMCLIENT, client_rec.DATENAISSANCE, client_rec.ADRESSE, client_rec.TELPROF, client_rec.TELPRIV, client_rec.FAX, client_rec.CLIENT_VEHICULE);
        DBMS_OUTPUT.PUT_LINE('Numéro Client : ' || client_obj.NUMCLIENT || ', Prénom : ' || client_obj.PRENOMCLIENT || ':');
        vehicules_li :=client_obj.lister_vehicules();
        FOR i IN 1..CARDINALITY(vehicules_li) LOOP
            DBMS_OUTPUT.PUT_LINE('Vehicle Reference: ' || vehicules_li(i).NUMVEHICULE);
        END LOOP;
    END LOOP;
END;
/


        
-- Methode 5: 
-- body
CREATE OR REPLACE PROCEDURE CalculerChiffreAffaireMarque AS
    CURSOR c_chiffre_affaire IS
        SELECT
            M.MARQUE AS MARQUE,
            SUM(I.COUTINTERV) AS CHIFFRE_DAFFAIRE
        FROM
            VEHICULE V
        JOIN
            INTERVENTIONS I ON V.NUMVEHICULE = I.INTERVENTIONS_VEHICULE.NUMVEHICULE
        JOIN
            MODELE MO ON V.VEHICULE_MODELE.NUMMODELE = MO.NUMMODELE
        JOIN
            MARQUE M ON MO.MODELE_MARQUE.NUMMARQUE = M.NUMMARQUE
        GROUP BY
            M.MARQUE;
BEGIN
    FOR chiffre_rec IN c_chiffre_affaire LOOP
        DBMS_OUTPUT.PUT_LINE('Marque: ' || chiffre_rec.MARQUE || ', Chiffre d''affaire: ' || chiffre_rec.CHIFFRE_DAFFAIRE);
    END LOOP;
END;
/
-- test Procedure
EXEC CalculerChiffreAffaireMarque;

/*********************Remplisage de donnees **********************/

-- 8. Remplir toutes les tables par les instances fournies en annexe.
-- insertions initiale: --
--table client
INSERT INTO CLIENT VALUES (1,'Mme','Cherifa','MAHBOUBA','08/08/1957','CITE 1013 LOGTS BT 61 Alger','0561381813','0562458714','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (2,'Mme','Lamia','TAHMI','31/12/1955','CITE BACHEDJARAH BATIMENT 38 -Bach Djerrah-Alger','0562467849','0561392487','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (3,'Mlle','Ghania','DIAF AMROUNI','31/12/1955','43RUE ABDERRAHMANE SBAABELLEVUE-EL HARRACH-ALGER','0523894562','0619430945','0562784254',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (4,'Mlle','Chahinaz','MELEK','27/06/1955','HLM AISSAT IDIR CAGE 9 3EME ETAGE-EL HARRACH ALGER','0634613493','0562529463','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (5,'Mme','Noura','TECHTACHE','22/03/1949','16, ROUTE EL DJAMILA-AINBENIAN-ALGER','0562757834','','0562757843',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (6,'Mme','Widad','TOUATI','14/08/1965','14 RUE DES FRERES AOUDIA-EL MOURADIA-ALGER','0561243967','0561401836','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (7,'Mlle','Faiza','ABLOUL','28/10/1967','CITE DIPLOMATIQUE BT BLEU 14B N 3 DERGANA- ALGER','0562935427','0561486203','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (8,'Mme','Assia','HORRA','08/12/1963','32 RUE AHMED OUAKED-DELY BRAHIM-ALGER','0561038500','','0562466733',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (9,'Mlle','Souad','MESBAH','30/08/1972','RESIDENCE CHABANI-HYDRA-ALGER','0561024358','','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (10,'Mme','Houda','GROUDA','20/02/1950','EPSP THNIET ELABED BATNA','0562939495','0561218456','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (11,'Mlle','Saida','FENNICHE','','CITE DE L''INDEPENDANCE LARBAA BLIDA','0645983165','0562014784','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (12,'Mme','Samia','OUALI','17/11/1966','CITE 200 LOGEMENTSBT1 N1-JIJEL','0561374812','0561277013','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (13,'Mme','Fatiha','HADDAD','20/09/1980','RUE BOUFADALAKHDARAT-AIN OULMANE-SETIF','0647092453','0562442700','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (14,'M','Djamel','MATI','','DRAA KEBILA HAMMAM GUERGOUR SETIF','0561033663','0561484259','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (15,'M','Mohamed','GHRAIR','24/06/1950','CITE JEANNE D''ARC ECRAN B5- GAMBETTA ORAN','0561390288','','0562375849',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (16,'M','Ali','LAAOUAR','','CITE 1ER MAIEX137LOGEMENTS-ADRAR','0639939410','0561255412','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (17,'M','Messoud','AOUIZ','24/11/1958','RUESAIDANI ABDESSLAM -AIN BESSEM-BOUIRA','0561439256','0561473625','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (18,'M','Farid','AKIL','06/05/1961','3RUELARBIBEN M''HIDI-DRAA EL MIZAN-TIZI OUZOU','0562349254','0561294268','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (19,'Mme','Dalila','MOUHTADI','','6, BD TRIPOLI ORAN','0506271459','0506294186','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (20,'M','Younes','CHALAH','','CITE DES 60LOGTS BTDN 48-NACIRIA-BOUMERDES','','0561358279','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (21,'M','Boubeker','BARKAT','08/11/1935','CITE MENTOURIN71BTABSMK Constantine','0561824538','0561326179','',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (22,'M','Seddik','HMIA','','25 RUE BEN YAHIYA-JIJEL','0562379513','','0562493627',t_set_ref_TVehicules());
INSERT INTO CLIENT VALUES (23,'M','Lamine','MERABAT','13/09/1965','CITE JEANNE D''ARC ECRAN B2-GAMBETTA ORAN','0561724538','0561724538','',t_set_ref_TVehicules());
select numclient from client;
--table employe 

INSERT INTO EMPLOYE VALUES(53,'LACHEMI','Bouzid','Mécanicien',25000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(54,'BOUCHEMLA','Elias','Assistant',10000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(55,'HADJ','Zouhir','Assistant',12000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(56,'OUSSEDIK','Hakim','Mécanicien',20000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(57,'ABAD','Abdelhamid','Assistant',13000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(58,'BABACI','Tayeb','Mécanicien',21300,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(59,'BELHAMIDI','Mourad','Mécanicien',19500,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(60,'IGOUDJIL','Redouane','Assistant',15000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(61,'KOULA','Bahim','Mécanicien',23100,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(62,'RAHALI','Ahcene','Mécanicien',24000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(63,'CHAOUI','Ismail','Assistant',13000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(64,'BADI','Hatem','Assistant',14000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(65,'MOHAMMEDI','Mustapha','Mécanicien',24000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(66,'FEKAR','Abdelaziz','Assistant',13500,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(67,'SAIDOUNI','Wahid','Mécanicien',25000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(68,'BOULARAS','Farid','Assistant',14000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(69,'CHAKER','Nassim','Mécanicien',26000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(71,'TERKI','Yacine','Mécanicien',23000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(72,'TEBIBEL','Ahmed','Assistant',17000,t_set_ref_TIntervenants());
INSERT INTO EMPLOYE VALUES(80,'LARDJOUNE','Karim','',25000,t_set_ref_TIntervenants());
select NUMEMPLOYE from employe;
-- table marque

INSERT INTO MARQUE VALUES(1,'LAMBORGHINI','ITALIE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(2,'AUDI','ALLEMAGNE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(3,'ROLLS-ROYCE','GRANDE-BRETAGNE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(4,'BMW','ALLEMAGNE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(5,'CADILLAC','ETATS-UNIS',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(6,'CHRYSLER','ETATS-UNIS',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(7,'FERRARI','ITALIE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(8,'HONDA','JAPON',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(9,'JAGUAR','GRANDE-BRETAGNE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(10,'ALFA-ROMEO','ITALIE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(11,'LEXUS','JAPON',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(12,'LOTUS','GRANDE-BRETAGNE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(13,'MASERATI','ITALIE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(14,'MERCEDES','ALLEMAGNE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(15,'PEUGEOT','FRANCE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(16,'PORSCHE','ALLEMAGNE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(17,'RENAULT','FRANCE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(18,'SAAB','SUEDE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(19,'TOYOTA','JAPON',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(20,'VENTURI','FRANCE',t_set_ref_Tmodel());
INSERT INTO MARQUE VALUES(21,'VOLVO','SUEDE',t_set_ref_Tmodel());
select nummarque from marque;
--table modele
INSERT INTO MODELE VALUES(2,'Diablo',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=1));
INSERT INTO MODELE VALUES(3,'Serie 5',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=2));
INSERT INTO MODELE VALUES(4,'NSX',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=10));
INSERT INTO MODELE VALUES(5,'Classe C',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=14));
INSERT INTO MODELE VALUES(6,'Safrane',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=17));
INSERT INTO MODELE VALUES(7,'400 GT',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=20));
INSERT INTO MODELE VALUES(8,'Esprit',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=12));
INSERT INTO MODELE VALUES(9,'605',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=15));
INSERT INTO MODELE VALUES(10,'Previa',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=19));
INSERT INTO MODELE VALUES(11,'550 Maranello',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=7));
INSERT INTO MODELE VALUES(12,'Bentley-Continental',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=3));
INSERT INTO MODELE VALUES(13,'Spider',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=10));
INSERT INTO MODELE VALUES(14,'Evoluzione',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=13));
INSERT INTO MODELE VALUES(15,'Carrera',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=16));
INSERT INTO MODELE VALUES(16,'Boxter',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=16));
INSERT INTO MODELE VALUES(17,'S 80',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=21));
INSERT INTO MODELE VALUES(18,'300 M',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=6));
INSERT INTO MODELE VALUES(19,'M 3',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=4));
INSERT INTO MODELE VALUES(20,'XJ 8',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=9));
INSERT INTO MODELE VALUES(21,'406 Coupe',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=15));
INSERT INTO MODELE VALUES(22,'300 Atlantic',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=20));
INSERT INTO MODELE VALUES(23,'Classe E',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=14));
INSERT INTO MODELE VALUES(24,'GS 300',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=11));
INSERT INTO MODELE VALUES(25,'Seville',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=5));
INSERT INTO MODELE VALUES(26,'95 Cabriolet',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=18));
INSERT INTO MODELE VALUES(27,'TT Coupé',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=2));
INSERT INTO MODELE VALUES(28,'F 355',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=7));
INSERT INTO MODELE VALUES(29,'POLO',t_set_ref_TVehicules(),(select ref(mq) from marque mq where mq. NUMMARQUE=45));
select nummodele from modele;
---table vehicule
INSERT INTO VEHICULE VALUES(1,0012519216,1992,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(2,0124219316,1993,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(3,1452318716,1987,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(4,3145219816,1998,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(5,1278919816,1998,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(6,3853319735,1997,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(7,1453119816,1998,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(8,8365318601,1986,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(9,3087319233,1992,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(10,9413119935,1999,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(11,1572319801,1998,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(12,6025319733,1997,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(13,5205319736,1997,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(14,7543119207,1992,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(15,6254319916,1999,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(16,9831419701,1997,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(17,4563117607,1976,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(18,7973318216,1982,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(19,3904318515,1985,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(20,1234319707,1997,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(21,8429318516,1985,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(22,1245619816,1998,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(23,1678918516,1985,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(24,1789519816,1998,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(25,1278919833,1998,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(26,1458919316,1993,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(27,1256019804,1998,t_set_ref_TIntervention(),null,null);
INSERT INTO VEHICULE VALUES(28,1986219904,1999,t_set_ref_TIntervention(),null,null);
select numvehicule from vehicule;
--table interventions
INSERT INTO INTERVENTIONS  VALUES(1,'Réparation',TO_DATE('2006-02-25 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-26 12:00:00','RRRR-MM-DD HH24:MI:SS'),30000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(2,'Réparation',TO_DATE('2006-02-23 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-24 18:00:00','RRRR-MM-DD HH24:MI:SS'),10000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(3,'Réparation',TO_DATE('2006-04-06 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-04-09 12:00:00','RRRR-MM-DD HH24:MI:SS'),42000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(4,'Entretien',TO_DATE('2006-05-14 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-14 18:00:00','RRRR-MM-DD HH24:MI:SS'),10000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(5,'Réparation',TO_DATE('2006-02-22 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-25 18:00:00','RRRR-MM-DD HH24:MI:SS'),40000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(6,'Entretien',TO_DATE('2006-03-03 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-03-04 18:00:00','RRRR-MM-DD HH24:MI:SS'),7500,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(7,'Entretien',TO_DATE('2006-04-09 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-04-09 18:00:00','RRRR-MM-DD HH24:MI:SS'),8000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(8,'Entretien',TO_DATE('2006-05-11 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-12 18:00:00','RRRR-MM-DD HH24:MI:SS'),9000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(9,'Entretien',TO_DATE('2006-02-22 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-22 18:00:00','RRRR-MM-DD HH24:MI:SS'),7960,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(10,'Entretien et Reparation',TO_DATE('2006-04-08 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-04-09 18:00:00','RRRR-MM-DD HH24:MI:SS'),45000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(11,'Réparation',TO_DATE('2006-03-08 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-03-17 12:00:00','RRRR-MM-DD HH:MI:SS'),36000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(12,'Entretien et Reparation',TO_DATE('2006-05-03 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-05 18:00:00','RRRR-MM-DD HH24:MI:SS'),27000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(13,'Réparation Systeme',TO_DATE('2006-05-12 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-12 18:00:00','RRRR-MM-DD HH24:MI:SS'),17846,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(14,'Réparation',TO_DATE('2006-05-10 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-12 12:00:00','RRRR-MM-DD HH24:MI:SS'),39000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(15,'Réparation Systeme',TO_DATE('2006-06-25 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-06-25 12:00:00','RRRR-MM-DD HH24:MI:SS'),27000,t_set_ref_TIntervenants(),null);
INSERT INTO INTERVENTIONS  VALUES(16,'Réparation',TO_DATE('2006-06-27 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-06-30 12:00:00','RRRR-MM-DD HH24:MI:SS'),25000,t_set_ref_TIntervenants(),null);
select numIntervention from interventions;
--table intervenants
INSERT INTO INTERVENANTS  VALUES(1,To_DATE('2006-02-26 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-26 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(2,TO_DATE('2006-02-25 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-25 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(3,TO_DATE('2006-02-24 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-24 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(4,TO_DATE('2006-02-23 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-24 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(5,TO_DATE('2006-04-09 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-04-09 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(6,TO_DATE('2006-04-06 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-04-08 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(7,TO_DATE('2006-05-14 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-14 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(8,TO_DATE('2006-02-14 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-14 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(9,TO_DATE('2006-02-22 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-25 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(10,TO_DATE('2006-02-23 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-25 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(11,TO_DATE('2006-03-03 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-03-04 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(12,TO_DATE('2006-03-04 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-03-04 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(13,TO_DATE('2006-04-09 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-04-09 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(14,TO_DATE('2006-04-09 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-04-09 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(15,TO_DATE('2006-05-12 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-12 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(16,TO_DATE('2006-05-11 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-12 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(17,TO_DATE('2006-02-22 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-22 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(18,TO_DATE('2006-02-22 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-22 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(19,TO_DATE('2006-04-09 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-04-09 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(20,TO_DATE('2006-04-08 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-04-09 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(21,TO_DATE('2006-03-09 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-03-11 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(22,TO_DATE('2006-03-09 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-03-17 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(23,TO_DATE('2006-03-08 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-03-16 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(24,TO_DATE('2006-05-05 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-05 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(25,TO_DATE('2006-05-03 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-05 12:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(26,TO_DATE('2006-05-12 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-12 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
INSERT INTO INTERVENANTS  VALUES(27,TO_DATE('2006-05-07 14:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-05-10 18:00:00','RRRR-MM-DD HH24:MI:SS'),null,null);
select numintervenants from intervenants;

-- insertions des associations (roles):  --
-- attribute : vehicule_client \ table: vehicule  --
-- after client --
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=2) where v.NUMVEHICULE=1 ;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=9) where v.NUMVEHICULE=2;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=17) where v.NUMVEHICULE=3 ;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=6) where v.NUMVEHICULE=4 ;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=16) where v.NUMVEHICULE=5 ;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=20) where v.NUMVEHICULE=6 ;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=7) where v.NUMVEHICULE=7 ;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=16) where v.NUMVEHICULE=8 ;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=13) where v.NUMVEHICULE=9;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=20) where v.NUMVEHICULE=10;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=9) where v.NUMVEHICULE=11;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=14) where v.NUMVEHICULE=12;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=19) where v.NUMVEHICULE=13;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=22) where v.NUMVEHICULE=14;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=4) where v.NUMVEHICULE=15;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=16) where v.NUMVEHICULE=16;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=12) where v.NUMVEHICULE=17;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=1) where v.NUMVEHICULE=18;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=18) where v.NUMVEHICULE=19;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=22) where v.NUMVEHICULE=20;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=3) where v.NUMVEHICULE=21;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=8) where v.NUMVEHICULE=22;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=7) where v.NUMVEHICULE=23;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=8) where v.NUMVEHICULE=24;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=13) where v.NUMVEHICULE=25;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=3) where v.NUMVEHICULE=26;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=10) where v.NUMVEHICULE=27;
update vehicule v set v.VEHICULE_CLIENT=(select ref(c) from client c where c.numclient=10) where v.NUMVEHICULE=28;

-- attribute : intervenants_employe \ table : intervenants --
--  after employe --  
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=54) where i.NUMINTERVENANTS=1;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=59) where i.NUMINTERVENANTS=2;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=57) where i.NUMINTERVENANTS=3;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=59) where i.NUMINTERVENANTS=4;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=60) where i.NUMINTERVENANTS=5;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=65) where i.NUMINTERVENANTS=6;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=62) where i.NUMINTERVENANTS=7;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=66) where i.NUMINTERVENANTS=8;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=56) where i.NUMINTERVENANTS=9;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=60) where i.NUMINTERVENANTS=10;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=53) where i.NUMINTERVENANTS=11;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=57) where i.NUMINTERVENANTS=12;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=55) where i.NUMINTERVENANTS=13;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=65) where i.NUMINTERVENANTS=14;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=54) where i.NUMINTERVENANTS=15;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=62) where i.NUMINTERVENANTS=16;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=59) where i.NUMINTERVENANTS=17;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=60) where i.NUMINTERVENANTS=18;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=63) where i.NUMINTERVENANTS=19;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=67) where i.NUMINTERVENANTS=20;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=59) where i.NUMINTERVENANTS=21;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=64) where i.NUMINTERVENANTS=22;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=53) where i.NUMINTERVENANTS=23;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=55) where i.NUMINTERVENANTS=24;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=56) where i.NUMINTERVENANTS=25;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=64) where i.NUMINTERVENANTS=26;
update intervenants i set i.Intervenants_Employe=(select ref(e) from employe e  where e.NUMEMPLOYE=88) where i.NUMINTERVENANTS=27;

--- update vehecule by modeles ref ---
--  after modele -- 
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=6) where v.NUMVEHICULE=1 ;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=20) where v.NUMVEHICULE=2;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=8) where v.NUMVEHICULE=3 ;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=12) where v.NUMVEHICULE=4 ;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=23) where v.NUMVEHICULE=5 ;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=6) where v.NUMVEHICULE=6 ;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=8) where v.NUMVEHICULE=7 ;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=14) where v.NUMVEHICULE=8 ;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=15) where v.NUMVEHICULE=9;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=22) where v.NUMVEHICULE=10;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=16) where v.NUMVEHICULE=11;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=20) where v.NUMVEHICULE=12;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=17) where v.NUMVEHICULE=13;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=21) where v.NUMVEHICULE=14;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=19) where v.NUMVEHICULE=15;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=21) where v.NUMVEHICULE=16;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=11) where v.NUMVEHICULE=17;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=2) where v.NUMVEHICULE=18;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=7) where v.NUMVEHICULE=19;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=2) where v.NUMVEHICULE=20;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=19) where v.NUMVEHICULE=21;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=19) where v.NUMVEHICULE=22;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=25) where v.NUMVEHICULE=23;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=9) where v.NUMVEHICULE=24;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=5) where v.NUMVEHICULE=25;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=10) where v.NUMVEHICULE=26;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=7) where v.NUMVEHICULE=27;
update vehicule v set v.Vehicule_Modele=(select ref(m) from modele m where m.nummodele=3) where v.NUMVEHICULE=28;

-- attribute : Marque_Modele \ table : marque -- 
--  after modele -- 
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=1)(select ref(m) from modele m where m.nummodele=2);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=2)(select ref(m) from modele m where m.nummodele=3);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=10)(select ref(m) from modele m where m.nummodele=4);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=14)(select ref(m) from modele m where m.nummodele=5);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=17)(select ref(m) from modele m where m.nummodele=6);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=20)(select ref(m) from modele m where m.nummodele=7);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=12)(select ref(m) from modele m where m.nummodele=8);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=15)(select ref(m) from modele m where m.nummodele=9);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=19)(select ref(m) from modele m where m.nummodele=10);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=7)(select ref(m) from modele m where m.nummodele=11);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=3)(select ref(m) from modele m where m.nummodele=12);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=10)(select ref(m) from modele m where m.nummodele=13);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=13)(select ref(m) from modele m where m.nummodele=14);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=16)(select ref(m) from modele m where m.nummodele=15);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=16)(select ref(m) from modele m where m.nummodele=16);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=21)(select ref(m) from modele m where m.nummodele=17);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=6)(select ref(m) from modele m where m.nummodele=18);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=4)(select ref(m) from modele m where m.nummodele=19);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=9)(select ref(m) from modele m where m.nummodele=20);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=15)(select ref(m) from modele m where m.nummodele=21);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=20)(select ref(m) from modele m where m.nummodele=22);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=14)(select ref(m) from modele m where m.nummodele=23);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=11)(select ref(m) from modele m where m.nummodele=24);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=5)(select ref(m) from modele m where m.nummodele=25);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=18)(select ref(m) from modele m where m.nummodele=26);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=2)(select ref(m) from modele m where m.nummodele=27);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=7)(select ref(m) from modele m where m.nummodele=28);
insert into table (select mq.Marque_Modele from marque mq where mq.nummarque=4)(select ref(m) from modele m where m.nummodele=29);

-- attribute: Modele_Vehicule \ table modele --
--  after vehicule -- 
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=6)(select ref(v) from vehicule v where v.NUMVEHICULE=1);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=20)(select ref(v) from vehicule v where v.NUMVEHICULE=2);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=8)(select ref(v) from vehicule v where v.NUMVEHICULE=3);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=12)(select ref(v) from vehicule v where v.NUMVEHICULE=4);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=23)(select ref(v) from vehicule v where v.NUMVEHICULE=5);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=6)(select ref(v) from vehicule v where v.NUMVEHICULE=6);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=8)(select ref(v) from vehicule v where v.NUMVEHICULE=7);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=14)(select ref(v) from vehicule v where v.NUMVEHICULE=8);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=15)(select ref(v) from vehicule v where v.NUMVEHICULE=9);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=22)(select ref(v) from vehicule v where v.NUMVEHICULE=10);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=16)(select ref(v) from vehicule v where v.NUMVEHICULE=11);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=20)(select ref(v) from vehicule v where v.NUMVEHICULE=12);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=17)(select ref(v) from vehicule v where v.NUMVEHICULE=13);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=21)(select ref(v) from vehicule v where v.NUMVEHICULE=14);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=19)(select ref(v) from vehicule v where v.NUMVEHICULE=15);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=21)(select ref(v) from vehicule v where v.NUMVEHICULE=16);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=11)(select ref(v) from vehicule v where v.NUMVEHICULE=17);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=2)(select ref(v) from vehicule v where v.NUMVEHICULE=18);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=7)(select ref(v) from vehicule v where v.NUMVEHICULE=19);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=2)(select ref(v) from vehicule v where v.NUMVEHICULE=20);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=19)(select ref(v) from vehicule v where v.NUMVEHICULE=21);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=19)(select ref(v) from vehicule v where v.NUMVEHICULE=22);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=25)(select ref(v) from vehicule v where v.NUMVEHICULE=23);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=9)(select ref(v) from vehicule v where v.NUMVEHICULE=24);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=5)(select ref(v) from vehicule v where v.NUMVEHICULE=25);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=10)(select ref(v) from vehicule v where v.NUMVEHICULE=26);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=7)(select ref(v) from vehicule v where v.NUMVEHICULE=27);
insert into table (select m.Modele_Vehicule from modele m where m.nummodele=3)(select ref(v) from vehicule v where v.NUMVEHICULE=28);

-- attribute : Client_vehicule  \ table: Client-- 
-- after vehicule  -- 
insert into table (select c.Client_Vehicule from client c where c.numclient=1)(select ref(v) from vehicule v where v.numvehicule=18);
insert into table (select c.Client_Vehicule from client c where c.numclient=10)(select ref(v) from vehicule v where v.numvehicule=28);
insert into table (select c.Client_Vehicule from client c where c.numclient=10)(select ref(v) from vehicule v where v.numvehicule=27);
insert into table (select c.Client_Vehicule from client c where c.numclient=3)(select ref(v) from vehicule v where v.numvehicule=21);
insert into table (select c.Client_Vehicule from client c where c.numclient=3)(select ref(v) from vehicule v where v.numvehicule=26);
insert into table (select c.Client_Vehicule from client c where c.numclient=13)(select ref(v) from vehicule v where v.numvehicule=25);
insert into table (select c.Client_Vehicule from client c where c.numclient=8)(select ref(v) from vehicule v where v.numvehicule=24);
insert into table (select c.Client_Vehicule from client c where c.numclient=7)(select ref(v) from vehicule v where v.numvehicule=23);
insert into table (select c.Client_Vehicule from client c where c.numclient=8)(select ref(v) from vehicule v where v.numvehicule=22);
insert into table (select c.Client_Vehicule from client c where c.numclient=22)(select ref(v) from vehicule v where v.numvehicule=20);
insert into table (select c.Client_Vehicule from client c where c.numclient=18)(select ref(v) from vehicule v where v.numvehicule=19);
insert into table (select c.Client_Vehicule from client c where c.numclient=12)(select ref(v) from vehicule v where v.numvehicule=17);
insert into table (select c.Client_Vehicule from client c where c.numclient=16)(select ref(v) from vehicule v where v.numvehicule=16);
insert into table (select c.Client_Vehicule from client c where c.numclient=4)(select ref(v) from vehicule v where v.numvehicule=15);
insert into table (select c.Client_Vehicule from client c where c.numclient=22)(select ref(v) from vehicule v where v.numvehicule=14);
insert into table (select c.Client_Vehicule from client c where c.numclient=19)(select ref(v) from vehicule v where v.numvehicule=13);
insert into table (select c.Client_Vehicule from client c where c.numclient=14)(select ref(v) from vehicule v where v.numvehicule=12);
insert into table (select c.Client_Vehicule from client c where c.numclient=9)(select ref(v) from vehicule v where v.numvehicule=11);
insert into table (select c.Client_Vehicule from client c where c.numclient=20)(select ref(v) from vehicule v where v.numvehicule=10);
insert into table (select c.Client_Vehicule from client c where c.numclient=13)(select ref(v) from vehicule v where v.numvehicule=9);
insert into table (select c.Client_Vehicule from client c where c.numclient=16)(select ref(v) from vehicule v where v.numvehicule=8);
insert into table (select c.Client_Vehicule from client c where c.numclient=7)(select ref(v) from vehicule v where v.numvehicule=7);
insert into table (select c.Client_Vehicule from client c where c.numclient=20)(select ref(v) from vehicule v where v.numvehicule=6);
insert into table (select c.Client_Vehicule from client c where c.numclient=16)(select ref(v) from vehicule v where v.numvehicule=5);
insert into table (select c.Client_Vehicule from client c where c.numclient=6)(select ref(v) from vehicule v where v.numvehicule=4);
insert into table (select c.Client_Vehicule from client c where c.numclient=17)(select ref(v) from vehicule v where v.numvehicule=3);
insert into table (select c.Client_Vehicule from client c where c.numclient=9)(select ref(v) from vehicule v where v.numvehicule=2);
insert into table (select c.Client_Vehicule from client c where c.numclient=2)(select ref(v) from vehicule v where v.numvehicule=1);

-- attribute : interventions \ table: interventions_vehicule --
--  after vehicule -- 
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=3) where i.NUMINTERVENTION=1 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=21) where i.NUMINTERVENTION=2 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=25) where i.NUMINTERVENTION=3 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=10) where i.NUMINTERVENTION=4 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=6) where i.NUMINTERVENTION=5 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=14) where i.NUMINTERVENTION=6 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=1) where i.NUMINTERVENTION=7 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=17) where i.NUMINTERVENTION=8 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=22) where i.NUMINTERVENTION=9 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=2) where i.NUMINTERVENTION=10 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=28) where i.NUMINTERVENTION=11 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=20) where i.NUMINTERVENTION=12 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=8) where i.NUMINTERVENTION=13 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=1) where i.NUMINTERVENTION=14 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=20) where i.NUMINTERVENTION=15 ;
update INTERVENTIONS i set i.INTERVENTIONS_VEHICULE=(select ref(v) from vehicule v where v.numvehicule=7) where i.NUMINTERVENTION=16 ;

--- attribute: Vehicule_interventions  \ table : vehicule -- 
--  after interventions -- 
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=3)(select ref(i) from interventions i where i.NUMINTERVENTION=1);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=21)(select ref(i) from interventions i where i.NUMINTERVENTION=2);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=25)(select ref(i) from interventions i where i.NUMINTERVENTION=3);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=10)(select ref(i) from interventions i where i.NUMINTERVENTION=4);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=6)(select ref(i) from interventions i where i.NUMINTERVENTION=5);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=14)(select ref(i) from interventions i where i.NUMINTERVENTION=6);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=1)(select ref(i) from interventions i where i.NUMINTERVENTION=7);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=17)(select ref(i) from interventions i where i.NUMINTERVENTION=8);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=22)(select ref(i) from interventions i where i.NUMINTERVENTION=9);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=2)(select ref(i) from interventions i where i.NUMINTERVENTION=10);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=28)(select ref(i) from interventions i where i.NUMINTERVENTION=11);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=20)(select ref(i) from interventions i where i.NUMINTERVENTION=12);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=8)(select ref(i) from interventions i where i.NUMINTERVENTION=13);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=1)(select ref(i) from interventions i where i.NUMINTERVENTION=14);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=20)(select ref(i) from interventions i where i.NUMINTERVENTION=15);
insert into table (select v.Vehicule_Interventions from vehicule v where v.numvehicule=7)(select ref(i) from interventions i where i.NUMINTERVENTION=16);

-- attribute : intervenants_interventions \ table : interventions  --
--  after interventions -- 
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=1) where i.NUMINTERVENANTS=1;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=1) where i.NUMINTERVENANTS=2;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=2) where i.NUMINTERVENANTS=3;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=2) where i.NUMINTERVENANTS=4;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=3) where i.NUMINTERVENANTS=5;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=3) where i.NUMINTERVENANTS=6;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=4) where i.NUMINTERVENANTS=7;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=4) where i.NUMINTERVENANTS=8;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=5) where i.NUMINTERVENANTS=9;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=5) where i.NUMINTERVENANTS=10;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=6) where i.NUMINTERVENANTS=11;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=6) where i.NUMINTERVENANTS=12;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=7) where i.NUMINTERVENANTS=13;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=7) where i.NUMINTERVENANTS=14;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=8) where i.NUMINTERVENANTS=15;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=8) where i.NUMINTERVENANTS=16;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=9) where i.NUMINTERVENANTS=17;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=9) where i.NUMINTERVENANTS=18;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=10) where i.NUMINTERVENANTS=19;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=10) where i.NUMINTERVENANTS=20;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=11) where i.NUMINTERVENANTS=21;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=11) where i.NUMINTERVENANTS=22;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=12) where i.NUMINTERVENANTS=23;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=12) where i.NUMINTERVENANTS=24;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=13) where i.NUMINTERVENANTS=25;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=13) where i.NUMINTERVENANTS=26;
update intervenants i set i.Intervenants_Interventions=(select ref(it) from interventions it  where it.NUMINTERVENTION=14) where i.NUMINTERVENANTS=27;

--attribute: employe_intervenant \ table: employer -- 
-- after intervenants --
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=54)(select ref(i) from intervenants i where i.NUMINTERVENANTS=1);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=59)(select ref(i) from intervenants i where i.NUMINTERVENANTS=2);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=57)(select ref(i) from intervenants i where i.NUMINTERVENANTS=3);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=59)(select ref(i) from intervenants i where i.NUMINTERVENANTS=4);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=60)(select ref(i) from intervenants i where i.NUMINTERVENANTS=5);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=65)(select ref(i) from intervenants i where i.NUMINTERVENANTS=6);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=62)(select ref(i) from intervenants i where i.NUMINTERVENANTS=7);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=66)(select ref(i) from intervenants i where i.NUMINTERVENANTS=8);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=56)(select ref(i) from intervenants i where i.NUMINTERVENANTS=9);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=60)(select ref(i) from intervenants i where i.NUMINTERVENANTS=10);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=53)(select ref(i) from intervenants i where i.NUMINTERVENANTS=11);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=57)(select ref(i) from intervenants i where i.NUMINTERVENANTS=12);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=55)(select ref(i) from intervenants i where i.NUMINTERVENANTS=13);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=65)(select ref(i) from intervenants i where i.NUMINTERVENANTS=14);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=54)(select ref(i) from intervenants i where i.NUMINTERVENANTS=15);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=62)(select ref(i) from intervenants i where i.NUMINTERVENANTS=16);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=59)(select ref(i) from intervenants i where i.NUMINTERVENANTS=17);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=60)(select ref(i) from intervenants i where i.NUMINTERVENANTS=18);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=63)(select ref(i) from intervenants i where i.NUMINTERVENANTS=19);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=67)(select ref(i) from intervenants i where i.NUMINTERVENANTS=20);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=59)(select ref(i) from intervenants i where i.NUMINTERVENANTS=21);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=64)(select ref(i) from intervenants i where i.NUMINTERVENANTS=22);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=53)(select ref(i) from intervenants i where i.NUMINTERVENANTS=23);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=55)(select ref(i) from intervenants i where i.NUMINTERVENANTS=24);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=56)(select ref(i) from intervenants i where i.NUMINTERVENANTS=25);
insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=64)(select ref(i) from intervenants i where i.NUMINTERVENANTS=26);
-- insert into table (select e.Employe_Intervenants from employe e where e.NUMEMPLOYE=88)(select ref(i) from intervenants i where i.NUMINTERVENANTS=27);
----------------------------------------------

--  attribute: interventions_intervenants \ table : interventions -- 
-- after intervenants -- 
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=1)(select ref(i) from intervenants i where i.numintervenants=1);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=1)(select ref(i) from intervenants i where i.numintervenants=2);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=2)(select ref(i) from intervenants i where i.numintervenants=3);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=2)(select ref(i) from intervenants i where i.numintervenants=4);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=3)(select ref(i) from intervenants i where i.numintervenants=5);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=3)(select ref(i) from intervenants i where i.numintervenants=6);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=4)(select ref(i) from intervenants i where i.numintervenants=7);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=4)(select ref(i) from intervenants i where i.numintervenants=8);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=5)(select ref(i) from intervenants i where i.numintervenants=9);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=5)(select ref(i) from intervenants i where i.numintervenants=10);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=6)(select ref(i) from intervenants i where i.numintervenants=11);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=6)(select ref(i) from intervenants i where i.numintervenants=12);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=7)(select ref(i) from intervenants i where i.numintervenants=13);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=7)(select ref(i) from intervenants i where i.numintervenants=14);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=8)(select ref(i) from intervenants i where i.numintervenants=15);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=8)(select ref(i) from intervenants i where i.numintervenants=16);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=9)(select ref(i) from intervenants i where i.numintervenants=17);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=9)(select ref(i) from intervenants i where i.numintervenants=18);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=10)(select ref(i) from intervenants i where i.numintervenants=19);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=10)(select ref(i) from intervenants i where i.numintervenants=20);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=11)(select ref(i) from intervenants i where i.numintervenants=21);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=11)(select ref(i) from intervenants i where i.numintervenants=22);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=11)(select ref(i) from intervenants i where i.numintervenants=23);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=12)(select ref(i) from intervenants i where i.numintervenants=24);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=12)(select ref(i) from intervenants i where i.numintervenants=25);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=13)(select ref(i) from intervenants i where i.numintervenants=26);
insert into table (select it.INTERVENTIONS_Intervenants from INTERVENTIONS it where it.numIntervention=14)(select ref(i) from intervenants i where i.numintervenants=27);
insertions.sql
Affichage de insertions.sql