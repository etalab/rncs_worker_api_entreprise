class TribunalInstance::EntrepriseRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe,    reader: ->(doc:, **) { doc.parent[:cod] }
  property :siren,          attribute: true
  property :numero_gestion, as: :num_gestion, attribute: true

  nested :idt do
    property :denomination,
      as: :nom_raison_soc,
      if: ->(doc:,  **) do
        TribunalInstance::EntrepriseRepresenter
          .numero_rcs_from(doc)
          .first != 'A'
      end

    property :nom_patronyme,
      as: :nom_raison_soc,
      if: ->(doc:, **) do
        TribunalInstance::EntrepriseRepresenter
          .numero_rcs_from(doc)
          .first == 'A'
      end

    property :prenoms,         as: :prenom
    property :forme_juridique, as: :code_form_jur
    property :associe_unique,  as: :assoc_unique

    nested :commerct do
      property :date_naissance,  as: :dat_naiss
      property :ville_naissance, as: :lieu_naiss
    end

    nested :activ do
      property :code_activite,       as: :ape_naf
      property :activite_principale, as: :activ_princip
    end

    nested :cap do
      property :capital,        as: :montant
      property :devise,         as: :devise
      property :capital_actuel, as: :montant_min
    end

    nested :durees do
      property :duree_pm
      property :date_cloture, as: :dat_cloture_jjmm
    end

    nested :divers do
      property :nom_usage
      property :pseudonyme, as: :pseudo
      property :sigle
      property :nom_commercial
      property :greffe_siege
      property :statut_edition_extrait, as: :statut_edit_extrait
      property :economie_sociale_solidaire, as: :ess_indic
    end

    nested :prem_exer do
      property :date_cloture_exceptionnelle, as: :dat_cloture
    end

    nested :domicil do
      property :domiciliataire_nom, as: :denom
      property :domiciliataire_rcs, as: :rcs
    end

    nested :eirl do
      property :eirl, as: :eirl_indic
      property :dap_denomnimation, as: :denom
      property :dap_object, as: :objet
      property :dap_date_cloture, as: :dat_cloture_jjmm
   end

    nested :auto_ent do
      property :auto_entrepreneur, as: :pp_indic
    end

    property :adresse_siege,
      as: :siege,
      decorator: TribunalInstance::AdresseSiegeRepresenter,
      class: TribunalInstance::AdresseSiege

    property :adresse_domiciliataire,
      as: :domicil,
      decorator: TribunalInstance::AdresseDomiciliataireRepresenter,
      class: TribunalInstance::AdresseDomiciliataire

    property :adresse_dap,
      as: :eirl,
      decorator: TribunalInstance::AdresseDAPRepresenter,
      class: TribunalInstance::AdresseDAP

  end

  collection :etablissements,
    as: :etab,
    wrap: :etabs,
    decorator: TribunalInstance::EtablissementRepresenter,
    class: TribunalInstance::Etablissement

  collection :representants,
    as: :rep,
    wrap: :reps,
    decorator: TribunalInstance::RepresentantRepresenter,
    class: TribunalInstance::Representant

  collection :observations,
    as: :proc, # procedure collective are observations
    wrap: :procs,
    decorator: TribunalInstance::ObservationRepresenter,
    class: TribunalInstance::Observation

  collection :actes,
    as: :act,
    wrap: :acts,
    decorator: TribunalInstance::ActeRepresenter,
    class: TribunalInstance::Acte

  collection :bilans,
    as: :bil,
    wrap: :bils,
    decorator: TribunalInstance::BilanRepresenter,
    class: TribunalInstance::Bilan

  private

  def self.numero_rcs_from(xml)
    xml
      .children
      .find { |c| c.name == 'rcs' }
      .children
      .text
  end
end
