class TribunalInstance::EtablissementRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe, reader: ->(doc:, **) { doc.parent.parent.parent[:cod] }
  property :type_etablissement, as: :categ

  nested :activ do
    property :siret
    property :activite, as: 'activité' # é...
    property :code_activite, as: :ape_naf
    property :date_debut_activite, as: :date_debut_activ
    property :origine_fonds, as: :orig_fonds
    property :type_activite, as: :type_activité # é...
  end

  property :enseigne
  property :nom_commercial, as: :nom_commerc

  nested :fonds do
    property :date_cessation_activite, as: :dat_cessat_activite
  end

  nested :exploitation do
    property :type_exploitation, as: :type
  end

  nested :prec_exploit do
    property :precedent_exploitant_nom, as: :nom
    property :precedent_exploitant_nom_usage, as: :nom_usage
    property :precedent_exploitant_prenom, as: :prenom
  end

  property :adresse,
    as:        :adr1,
    decorator: TribunalInstance::AdresseEtablissementRepresenter,
    class:     TribunalInstance::AdresseEtablissement
end
