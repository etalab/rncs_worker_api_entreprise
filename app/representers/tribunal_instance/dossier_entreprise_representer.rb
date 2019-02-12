class TribunalInstance::DossierEntrepriseRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe,    reader: ->(doc:, **) { doc.parent[:cod] }
  property :siren,          attribute: true
  property :numero_gestion, as: :num_gestion, attribute: true

  property :type_inscription,           default: 'P'
  property :nom_greffe,                 default: 'fix me with a config file'
  property :date_derniere_modification, as: :dat_donnees, attribute: true
  property :date_immatriculation

  nested :idt do
    property :numero_rcs,      as: :rcs

    nested :radiation do
      property :code_radiation,  as: :code
      property :motif_radiation, as: :motif
    end

    nested :rad do
      property :date_radiation, as: :dat
    end

    nested :immat do
      property :date_immatriculation,          as: :dat
      property :date_premiere_immatriculation, as: :dat_prem_immat
    end

    nested :dern_ajout do
      property :date_transfert, as: :dat_trsft_siege
    end
  end
end
