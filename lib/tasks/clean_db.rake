task clean_db: :environment do
  sql = <<-ENDSQL
  TRUNCATE dossiers_entreprises,
  personnes_morales,
  personnes_physiques,
  representants,
  etablissements,
  observations
  ENDSQL

  ActiveRecord::Base.connection.execute(sql)
end
