module DataSource
  module File
    module PP
      module Operation
        class Store < Trailblazer::Operation
          include DataSource::File::Helper

          step :csv_to_hash
          step :rework_keys
          step :deserialize_params
          step :insert_into_database

          def rework_keys(ctx, data:, **)
            data.map! do |e|
              e[:date_premiere_immatriculation] = e.delete(:date_1re_immatriculation)
              e[:sans_activite] = e.delete(:sans_activité)
              e[:date_debut_activite] = e.delete(:date_debut_activité)
              e[:date_debut_premiere_activite] = e.delete(:date_début_1re_activité)
              e[:date_cessation_activite] = e.delete(:date_cessation_activité)
              e[:nom_patronyme] = e.delete(:nom_patronymique)
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

          def deserialize_params(ctx, data:, **)
            data.map! do |e|
              nested_identite = e[:identite] = {}
              nested_identite[:nom_patronyme] = e.delete(:nom_patronyme)
              nested_identite[:nom_usage] = e.delete(:nom_usage)
              nested_identite[:pseudonyme] = e.delete(:pseudonyme)
              nested_identite[:prenoms] = e.delete(:prenoms)
              nested_identite[:date_naissance] = e.delete(:date_naissance)
              nested_identite[:ville_naissance] = e.delete(:ville_naissance)
              nested_identite[:pays_naissance] = e.delete(:pays_naissance)
              nested_identite[:nationalite] = e.delete(:nationalite)

              nested_identite = e[:conjoint_collaborateur_identite] = {}
              nested_identite[:nom_patronyme] = e.delete(:conjoint_collab_nom_patronym)
              nested_identite[:nom_usage] = e.delete(:conjoint_collab_nom_usage)
              nested_identite[:pseudonyme] = e.delete(:conjoint_collab_pseudo)
              nested_identite[:prenoms] = e.delete(:conjoint_collab_prénoms)

              nested_adresse = e[:adresse] = {}
              nested_adresse[:ligne_1] = e.delete(:adresse_ligne1)
              nested_adresse[:ligne_2] = e.delete(:adresse_ligne2)
              nested_adresse[:ligne_3] = e.delete(:adresse_ligne3)
              nested_adresse[:code_postal] = e.delete(:code_postal)
              nested_adresse[:ville] = e.delete(:ville)
              nested_adresse[:code_commune] = e.delete(:commune)
              nested_adresse[:pays] = e.delete(:pays)

              nested_adresse = e[:dap_adresse] = {}
              nested_adresse[:ligne_1] = e.delete(:dap_adresse_ligne1)
              nested_adresse[:ligne_2] = e.delete(:dap_adresse_ligne2)
              nested_adresse[:ligne_3] = e.delete(:dap_adresse_ligne3)
              nested_adresse[:code_postal] = e.delete(:dap_code_postal)
              nested_adresse[:ville] = e.delete(:dap_ville)
              nested_adresse[:code_commune] = e.delete(:dap_code_commune)
              nested_adresse[:pays] = e.delete(:dap_pays)

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
