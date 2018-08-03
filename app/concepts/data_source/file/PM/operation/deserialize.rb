module DataSource
  module File
    module PM
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
              e[:associe_unique] = e.delete(:associé_unique)
              e[:activite_principale] = e.delete(:activité_principale)
              e[:date_cloture] = e.delete(:date_clôture)
              e[:date_cloture_exeptionnelle] = e.delete(:"date_clôture_except.")
              e[:duree_pm] = e.delete(:durée_pm)
              e[:date_derniere_modification] = e.delete(:date_greffe)
              e[:libelle_derniere_modification] = e.delete(:libelle_evt)

              e
            end
          end

          def deserialize(ctx, raw_data:, **)
            raw_data.map! do |e|
              nested_personne_morale = e[:personne_morale] = {}
              nested_personne_morale[:denomination] = e.delete(:denomination)
              nested_personne_morale[:sigle] = e.delete(:sigle)
              nested_personne_morale[:forme_juridique] = e.delete(:forme_juridique)
              nested_personne_morale[:associe_unique] = e.delete(:associe_unique)
              nested_personne_morale[:activite_principale] = e.delete(:activite_principale)
              nested_personne_morale[:type_capital] = e.delete(:type_capital)
              nested_personne_morale[:capital] = e.delete(:capital)
              nested_personne_morale[:capital_actuel] = e.delete(:capital_actuel)
              nested_personne_morale[:devise] = e.delete(:devise)
              nested_personne_morale[:date_cloture] = e.delete(:date_cloture)
              nested_personne_morale[:date_cloture_exeptionnelle] = e.delete(:date_cloture_exeptionnelle)
              nested_personne_morale[:economie_sociale_solidaire] = e.delete(:economie_sociale_solidaire)
              nested_personne_morale[:duree_pm] = e.delete(:duree_pm)
              nested_personne_morale[:date_derniere_modification] = e.delete(:date_derniere_modification)
              nested_personne_morale[:libelle_derniere_modification] = e.delete(:libelle_derniere_modification)

              e
            end
          end
        end
      end
    end
  end
end
