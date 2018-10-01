module DataSource
  module Stock
    module TribunalCommerce
      module Operation
        class PostImport < Trailblazer::Operation
          step :import_completed?
          step :create_db_indexes
          step :fill_in_foreign_keys


          def import_completed?(ctx, stock_unit:, **)
            overall_import = stock_unit.stock
            overall_import.status == 'COMPLETED'
          end

          def create_db_indexes(ctx, **)
            sql = 'CREATE INDEX IF NOT EXISTS index_dossier_entreprise_enregistrement_id ON dossiers_entreprises (code_greffe, numero_gestion, siren);'
            ActiveRecord::Base.connection.execute(sql)
          end

          def fill_in_foreign_keys(ctx, **)
            [
              'personnes_morales',
              'personnes_physiques',
              'representants',
              'etablissements',
              'observations',
            ]
              .each do |t|
              sql = <<-END_SQL
              UPDATE #{t}
              SET dossier_entreprise_id = dossiers_entreprises.id
              FROM dossiers_entreprises
              WHERE #{t}.code_greffe = dossiers_entreprises.code_greffe
              AND #{t}.numero_gestion = dossiers_entreprises.numero_gestion
              AND #{t}.siren = dossiers_entreprises.siren
              END_SQL
              ActiveRecord::Base.connection.execute(sql)
            end
          end
        end
      end
    end
  end
end
