module DataSource
  module File
    module PP
      module Operation
        class Store < Trailblazer::Operation
          include DataSource::File::Helper

          step :csv_to_hash
          step :rework_keys
          step :insert_into_database

          def rework_keys(ctx, data:, **)
            data.map! do |e|
              e[:date_premiere_immatriculation] = e.delete(:date_1re_immatriculation)
              e[:sans_activite] = e.delete(:sans_activité)
              e[:date_debut_activite] = e.delete(:date_debut_activité)
              e[:date_debut_premiere_activite] = e.delete(:date_début_1re_activité)
              e[:date_cessation_activite] = e.delete(:date_cessation_activité)
              e[:prenoms] = e.delete(:prénoms)
              e[:nationalite] = e.delete(:nationalité)
              e[:activite_forain] = e.delete(:activité_forain)
              e[:dap_denomination] = e.delete(:dap_dénomination)
              e[:dap_date_cloture] = e.delete(:dap_date_clôture)
              e[:date_derniere_modification] = e.delete(:date_greffe)
              e[:libelle_derniere_modification] = e.delete(:libelle_evt)

              e
            end
          end

          def insert_into_database(ctx, data:, **)
            data.each do |row|
              create_entreprise = Entreprise::Operation::Create.call(params: row)
              if create_entreprise.success?
                row[:entreprise_id] = create_entreprise[:model].id
                create_personne_physique = PersonnePhysique::Operation::Create.call(params: row)
              end
            end
          end
        end
      end
    end
  end
end
