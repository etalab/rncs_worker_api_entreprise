module DataSource
  module File
    module PP
      module Operation
        class Deserialize < Trailblazer::Operation
          step :rework_keys
          step :deserialize

          def rework_keys(ctx, raw_data:, **)
            raw_data.map! do |e|
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

          def deserialize(ctx, raw_data:, **)
            raw_data.map! do |e|
              nested_personne_physique = e[:personne_physique] = {}
              nested_personne_physique[:activite_forain] = e.delete(:activite_forain)
              nested_personne_physique[:dap] = e.delete(:dap)
              nested_personne_physique[:dap_denomination] = e.delete(:dap_denomination)
              nested_personne_physique[:dap_objet] = e.delete(:dap_objet)
              nested_personne_physique[:dap_date_cloture] = e.delete(:dap_date_cloture)
              nested_personne_physique[:eirl] = e.delete(:eirl)
              nested_personne_physique[:auto_entrepreneur] = e.delete(:auto_entrepreneur)
              nested_personne_physique[:conjoint_collaborateur_date_fin] = e.delete(:conjoint_collaborateur_date_fin)

              nested_identite = nested_personne_physique[:identite] = {}
              nested_identite[:nom_patronyme] = e.delete(:nom_patronyme)
              nested_identite[:nom_usage] = e.delete(:nom_usage)
              nested_identite[:pseudonyme] = e.delete(:pseudonyme)
              nested_identite[:prenoms] = e.delete(:prenoms)
              nested_identite[:date_naissance] = e.delete(:date_naissance)
              nested_identite[:ville_naissance] = e.delete(:ville_naissance)
              nested_identite[:pays_naissance] = e.delete(:pays_naissance)
              nested_identite[:nationalite] = e.delete(:nationalite)

              nested_identite = nested_personne_physique[:conjoint_collaborateur_identite] = {}
              nested_identite[:nom_patronyme] = e.delete(:conjoint_collab_nom_patronym)
              nested_identite[:nom_usage] = e.delete(:conjoint_collab_nom_usage)
              nested_identite[:pseudonyme] = e.delete(:conjoint_collab_pseudo)
              nested_identite[:prenoms] = e.delete(:conjoint_collab_prénoms)

              nested_adresse = nested_personne_physique[:adresse] = {}
              nested_adresse[:ligne_1] = e.delete(:adresse_ligne1)
              nested_adresse[:ligne_2] = e.delete(:adresse_ligne2)
              nested_adresse[:ligne_3] = e.delete(:adresse_ligne3)
              nested_adresse[:code_postal] = e.delete(:code_postal)
              nested_adresse[:ville] = e.delete(:ville)
              nested_adresse[:code_commune] = e.delete(:commune)
              nested_adresse[:pays] = e.delete(:pays)

              nested_adresse = nested_personne_physique[:dap_adresse] = {}
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
        end
      end
    end
  end
end
