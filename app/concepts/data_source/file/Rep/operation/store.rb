module DataSource
  module File
    module Rep
      module Operation
        class Store < Trailblazer::Operation
          include DataSource::File::Helper

          step :rename_csv_headers
          step :csv_to_hash
          step :rework_keys
          step :insert_into_database

          def rework_keys(ctx, data:, **)
            data.map! do |e|
              e[:siren_pm] = e.delete(:siren)
              e[:siren] = e.delete(:siren_entreprise)
              e[:nom_patronyme] = e.delete(:nom_patronymique)
              e[:prenoms] = e.delete(:prénoms)
              e[:denomination] = e.delete(:dénomination)
              e[:nationalite] = e.delete(:nationalité)
              e[:qualite] = e.delete(:qualité)
              e[:rep_perm_prenoms] = e.delete(:rep_perm_prénoms)
              e[:rep_perm_nationalite] = e.delete(:rep_perm_nationalité)
              e[:conjoint_collab_prenoms] = e.delete(:conjoint_collab_prénoms)
              e[:id_representant] = e.delete(:id_représentant)
              e[:date_derniere_modification] = e.delete(:date_greffe)
              e[:libelle_derniere_modification] = e.delete(:libelle_evt)

              e
            end
          end

          def insert_into_database(ctx, data:, **)
            data.each do |row|
              create_representant = Representant::Operation::Create.call(params: row)
            end
          end

          def rename_csv_headers(ctx, file_path:, **)
            `sed -i -e '1s/Nom_Greffe;Numero_Gestion;Siren;Type;/Nom_Greffe;Numero_Gestion;Siren_Entreprise;Type;/' #{file_path}`
          end
        end
      end
    end
  end
end
