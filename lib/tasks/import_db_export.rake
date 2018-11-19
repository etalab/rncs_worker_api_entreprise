task import_db_export: :environment do
  class ImportCSVDump < Trailblazer::Operation
    extend TrailblazerHelper::DBIndexes

    step ->(ctx, **) do
      drop_queries.each { |query| ActiveRecord::Base.connection.execute(query) }
    end

    step ->(ctx, folder:, **) do
      file_path = File.join(folder, '20181118-pm.csv')
      mapping = QUICKWIN_DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING
      import_file(file_path, mapping, DossierEntreprise)
    end

    step ->(ctx, folder:, **) do
      file_path = File.join(folder, '20181118-pm.csv')
      mapping = QUICKWIN_PM_HEADER_MAPPING
      import_file(file_path, mapping, PersonneMorale)
    end

    step ->(ctx, folder:, **) do
      file_path = File.join(folder, '20181118-pp.csv')
      mapping = QUICKWIN_DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING
      import_file(file_path, mapping, DossierEntreprise)
    end

    step ->(ctx, folder:, **) do
      file_path = File.join(folder, '20181118-pp.csv')
      mapping = QUICKWIN_PP_HEADER_MAPPING
      import_file(file_path, mapping, PersonnePhysique)
    end

    step ->(ctx, folder:, **) do
      file_path = File.join(folder, '20181118-rep.csv')
      mapping = QUICKWIN_REP_HEADER_MAPPING
      import_file(file_path, mapping, Representant)
    end

    step ->(ctx, folder:, **) do
      file_path = File.join(folder, '20181118-ets.csv')
      mapping = QUICKWIN_ETS_HEADER_MAPPING
      import_file(file_path, mapping, Etablissement)
    end

    step ->(ctx, folder:, **) do
      file_path = File.join(folder, '20181118-obs.csv')
      mapping = QUICKWIN_OBS_HEADER_MAPPING
      import_file(file_path, mapping, Observation)
    end

    def self.import_file(file_path, mapping, model)
      DataSource::File::CSVReader.bulk_processing(file_path, mapping) do |batch|
        model.import(batch)
      end
    end
  end

  ImportCSVDump.call(folder: '/home/deploy/rncs_data/uptodate_stock')
end
