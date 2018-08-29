task clean_db: :environment do
  Identite.delete_all
  Adresse.delete_all
  Etablissement.delete_all
  Representant.delete_all
  PersonnePhysique.delete_all
  PersonneMorale.delete_all
  Observation.delete_all
  Entreprise.delete_all
end
