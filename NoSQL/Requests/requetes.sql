-- 1* Afficher tous les véhicules de la marque «PORSCHE»
db.getCollection("Vehicule").find({"MODELE.MARQUE.MARQUE": "PORSCHE"}) /*dans la table vehicule on lance la requete find()*/

-- 2** Récupérer dans une nouvelle collection Véhicules_Interventions, les matricules des véhicules et
-- le nombre total de s interventions par véhicule ; la collection devra être ordonnée par ordre
-- décroissant du nombre des interventions.

db.Vehicule.aggregate([
    {
        "$project": {
            "_id": 0,
            "NUMVEHICULE": 1,
            "NUMIMMAT": 1,
            "nombre_interventions": {
                "$cond": {
                    "if": { "$gt": [{ "$size": { "$ifNull": ["$INTERVENTIONS", []] } }, 0] },
                    "then": { "$size": "$INTERVENTIONS" },
                    "else": 0
                }
            }
        }
    },
    {
        "$sort": {
            "nombre_interventions": -1
        }
    },
    {
        "$out": "Véhicules_Interventions"
    }
]);


-- 3** Dans une collection véhicule_bcp_pannes, récupérer les véhicules dont le nombre des
-- interventions dépasse 6 pannes.

db.Vehicules_Interventions.aggregate([
    {
        "$match": {
            "nombre_interventions": { "$gt": 6 } 
        }
    },
    {
        "$out": "véhicule_bcp_pannes"
    }
]);



-- 4** Récupérer dans une collection employe-interv, toutes les interventions d’un employé.

db.getCollection("Vehicule").aggregate([
  // Étape de désagrégation pour obtenir un document par intervention
  { $unwind: "$INTERVENTIONS" },
  { $unwind: "$INTERVENTIONS.INTERVENANTS" },
  {
    $project: {
      _id: 0,
      NUMEMPLOYE: "$INTERVENTIONS.INTERVENANTS.NUMEMPLOYE",
      NUMINTERVENTION: "$INTERVENTIONS.NUMINTERVENTION"
    }
  },
  {
    $group: {
      _id: "$NUMEMPLOYE",
      nombre_interventions: { $sum: 1 }, 
      interventions: { $push: "$$ROOT" } 
    }
  },
  { $out: "employe-interv" }
]);


-- question 5 :Augmenter de 8000DA, le salaire des employés de catégorie « Mécanicien»

db.Vehicule.updateMany(
   { "INTERVENTIONS.INTERVENANTS.CATEGORIE": "Mécanicien" },
   { $inc: { "INTERVENTIONS.$[].INTERVENANTS.$[mechanic].SALAIRE": 8000 } },
   { arrayFilters: [{ "mechanic.CATEGORIE": "Mécanicien" }] }
)


-- question 6: Reprendre la 4ième requête à l’aide du paradigme Map-Reduce.

db.Vehicule.mapReduce(
  // Fonction de map
  function() {
    if (!this.INTERVENTIONS) return; 
    this.INTERVENTIONS.forEach(function(intervention) {
      if (!intervention.INTERVENANTS) return; 
      intervention.INTERVENANTS.forEach(function(intervenant) {
        emit(intervenant.NUMEMPLOYE, {
          NUMINTERVENTION: intervention.NUMINTERVENTION,
          TYPEINTERVENTION: intervention.TYPEINTERVENTION,
          COUTINTERV: intervention.COUTINTERV
        });
      });
    });
  },
  // Fonction de reduce
  function(key, values) {
    var result = {
      nombre_interventions: values.length, 
      interventions: values
    };
    return result;
  },
  {
    out: "Employe-Interv2", 
    scope: { } 
  }
);