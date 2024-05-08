/*************Lister les modèles et leur marque ******************/
SELECT m.NUMMODELE, m.MODELE, DEREF(m.MODELE_MARQUE).MARQUE FROM MODELE m;
/*************Lister les véhicules sur les quels, il y a au moins une intervention*******/
SELECT v.NUMVEHICULE, v.NUMIMMAT, v.ANNEE FROM VEHICULE v
WHERE EXISTS (SELECT 1 FROM TABLE(v.VEHICULE_INTERVENTIONS));
/*************Quelle est la durée moyenne d’une intervention?*********/
SELECT NUMINTERVENTION ,AVG(DATEFININTERV - DATEDEBINTERV) AS DureeMoyenneIntervention FROM INTERVENTIONS GROUP BY NUMINTERVENTION; /* Le resultat est exprimer en jour */
/*************Donner le montant global des interventions dont le coût d’intervention est supérieur à 30000 DA?*/
-- chaque intervention contien plusieur intervenants donc on multiplie le nombre d'intervenant par le cout d'une seul intervention 
SELECT NUMINTERVENTION, SUM(MontantGlobal) AS MontantGlobal
FROM (
    SELECT NUMINTERVENTION, COUTINTERV * CARDINALITY(INTERVENTIONS_INTERVENANTS) AS MontantGlobal
    FROM INTERVENTIONS
)
GROUP BY NUMINTERVENTION
HAVING SUM(MontantGlobal) > 30000;

/************Donner la liste des employés ayant fait le plus grand nombre d’interventions.********/
SELECT deref(INTERVENANTS_EMPLOYE).NUMEMPLOYE AS NUMEMPLOYE , COUNT(*) AS NOMBREINTERVENTIONS FROM INTERVENANTS
GROUP BY deref(INTERVENANTS_EMPLOYE).NUMEMPLOYE
ORDER BY NOMBREINTERVENTIONS DESC;