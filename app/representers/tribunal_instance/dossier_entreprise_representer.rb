class TribunalInstance::DossierEntrepriseRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe,    reader: ->(doc:, **) { doc.parent[:cod] }
  property :siren,          attribute: true
  property :numero_gestion, as: :num_gestion, attribute: true

  property :type_inscription, default: 'P'
  property :nom_greffe, reader: ->(represented:, **) {
    TribunalInstance::DossierEntrepriseRepresenter
      .nom_greffe(represented.code_greffe)
  }
  property :date_derniere_modification, as: :dat_donnees, attribute: true
  property :date_immatriculation

  nested :idt do
    property :numero_rcs, as: :rcs

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

  def self.nom_greffe(code_greffe)
    ::YAML.load_file('config/codes_greffes_tribunal_instance.yml')
      .find { |e| e.key?(code_greffe) }&.values&.first
  end
end
