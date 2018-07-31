module DataSource
  module File
    module Ets
      module Operation
        class Store < Trailblazer::Operation
          include DataSource::File::Helper

          step :csv_to_hash
          step :rework_keys
          step :deserialize_params
          step :insert_into_database


          def rework_keys(ctx, data:, **)
            data.map! do |e|
              e[:type_etablissement] = e.delete(:type)
              e[:siege_pm] = e.delete(:siège_pm)
              e[:domiciliataire_complement] = e.delete(:domiciliataire_complément)
              e[:siege_domicile_representant] = e.delete(:siege_domicile_représentant)
              e[:activite_ambulante] = e.delete(:activité_ambulante)
              e[:activite_saisonniere] = e.delete(:activité_saisonnière)
              e[:activite_non_sedentaire] = e.delete(:activité_non_sédentaire)
              e[:date_debut_activite] = e.delete(:date_début_activité)
              e[:activite] = e.delete(:activité)
              e[:date_derniere_modification] = e.delete(:date_greffe)
              e[:libelle_derniere_modification] = e.delete(:libelle_evt)

              e
            end
          end

          def deserialize_params(ctx, data:, **)
            data.map! do |e|
              nested_adresse = e[:adresse] = {}
              nested_adresse[:ligne_1] = e.delete(:adresse_ligne1)
              nested_adresse[:ligne_2] = e.delete(:adresse_ligne2)
              nested_adresse[:ligne_3] = e.delete(:adresse_ligne3)
              nested_adresse[:code_postal] = e.delete(:code_postal)
              nested_adresse[:ville] = e.delete(:ville)
              nested_adresse[:code_commune] = e.delete(:commune)
              nested_adresse[:pays] = e.delete(:pays)

              e
            end
          end

          def insert_into_database(ctx, data:, **)
            data.each do |row|
              create_etablissement = Etablissement::Operation::Create.call(params: row)
            end
          end
        end
      end
    end
  end
end
