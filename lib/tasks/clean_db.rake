task clean_db: :environment do
  Etablissement.delete_all
  Representant.delete_all
  PersonnePhysique.delete_all
  PersonneMorale.delete_all
  Observation.delete_all
  DossierEntreprise.delete_all
end
