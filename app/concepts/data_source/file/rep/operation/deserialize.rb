module DataSource
  module File
    module Rep
      module Operation
        class Deserialize < Trailblazer::Operation
          step :rework_keys
          step :deserialize

          def rework_keys(ctx, raw_data:, **)
            raw_data.map! do |e|
              e[:type_representant] = e.delete(:type)
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

          def deserialize(ctx, raw_data:, **)
            raw_data.map! do |e|
              nested_identite = e[:identite] = {}
              nested_identite[:nom_patronyme] = e.delete(:nom_patronyme)
              nested_identite[:nom_usage] = e.delete(:nom_usage)
              nested_identite[:pseudonyme] = e.delete(:pseudonyme)
              nested_identite[:prenoms] = e.delete(:prenoms)
              nested_identite[:date_naissance] = e.delete(:date_naissance)
              nested_identite[:ville_naissance] = e.delete(:ville_naissance)
              nested_identite[:pays_naissance] = e.delete(:pays_naissance)
              nested_identite[:nationalite] = e.delete(:nationalite)

              nested_identite = e[:representant_permanent_identite] = {}
              nested_identite[:nom_patronyme] = e.delete(:rep_perm_nom)
              nested_identite[:nom_usage] = e.delete(:rep_perm_nom_usage)
              nested_identite[:pseudonyme] = e.delete(:rep_perm_pseudo)
              nested_identite[:prenoms] = e.delete(:rep_perm_prenoms)
              nested_identite[:date_naissance] = e.delete(:rep_perm_date_naissance)
              nested_identite[:ville_naissance] = e.delete(:rep_perm_ville_naissance)
              nested_identite[:pays_naissance] = e.delete(:rep_perm_pays_naissance)
              nested_identite[:nationalite] = e.delete(:rep_perm_nationalite)

              nested_identite = e[:conjoint_collaborateur_identite] = {}
              nested_identite[:nom_patronyme] = e.delete(:conjoint_collab_nom_patronym)
              nested_identite[:nom_usage] = e.delete(:conjoint_collab_nom_usage)
              nested_identite[:pseudonyme] = e.delete(:conjoint_collab_pseudo)
              nested_identite[:prenoms] = e.delete(:conjoint_collab_prenoms)

              nested_adresse = e[:adresse] = {}
              nested_adresse[:ligne_1] = e.delete(:adresse_ligne1)
              nested_adresse[:ligne_2] = e.delete(:adresse_ligne2)
              nested_adresse[:ligne_3] = e.delete(:adresse_ligne3)
              nested_adresse[:code_postal] = e.delete(:code_postal)
              nested_adresse[:ville] = e.delete(:ville)
              nested_adresse[:code_commune] = e.delete(:commune)
              nested_adresse[:pays] = e.delete(:pays)

              nested_adresse = e[:representant_permanent_adresse] = {}
              nested_adresse[:ligne_1] = e.delete(:rep_perm_adr_ligne1)
              nested_adresse[:ligne_2] = e.delete(:rep_perm_adr_ligne2)
              nested_adresse[:ligne_3] = e.delete(:rep_perm_adr_ligne3)
              nested_adresse[:code_postal] = e.delete(:rep_perm_code_postal)
              nested_adresse[:ville] = e.delete(:rep_perm_ville)
              nested_adresse[:code_commune] = e.delete(:rep_perm_code_commune)
              nested_adresse[:pays] = e.delete(:rep_perm_pays)

              e
            end
          end
        end
      end
    end
  end
end
