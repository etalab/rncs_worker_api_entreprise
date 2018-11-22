task clean_db: :environment do
  sql = <<-ENDSQL
  TRUNCATE dossiers_entreprises,
  personnes_morales,
  personnes_physiques,
  representants,
  etablissements,
  observations,
  stocks,
  stock_units,
  daily_updates,
  daily_update_units;
  ENDSQL

  ActiveRecord::Base.connection.execute(sql)
end
