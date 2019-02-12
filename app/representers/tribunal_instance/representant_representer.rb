class TribunalInstance::RepresentantRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe, reader: ->(doc:, **) { doc.parent.parent.parent[:cod] }
  property :qualite, as: :qual
  property :raison_sociale_ou_nom_ou_prenom, as: :rais_nom
  property :nom_ou_denomination, as: :nom_denom
  property :prenoms, as: :prenom
  property :type_representant, as: :type_dir
  property :date_creation, as: :dat_crea_rep
  property :date_modification, as: :dat_modif
  property :date_radiation, as: :dat_radiation

  property :adresse_representant,
    as: :adr1,
    decorator: TribunalInstance::AdresseRepresentantRepresenter,
    class: TribunalInstance::AdresseRepresentant

  nested :pers_physique do
    property :pseudonyme, as: :pseudo
    property :date_naissance, as: :dat_naiss
    property :ville_naissance, as: :lieu_naiss
    property :pays_naissance, as: :rep_pays_naiss
    property :nationalite, as: :nation
    property :nom_usage, as: :rep_nom_usage
  end

  nested :pers_mor do
    property :greffe_immatriculation, as: :greffe_immat
    property :siren_ou_numero_gestion, as: :siren_num_gestion
    property :forme_juridique, as: :form_jur
    property :commentaire, as: :rep_comment

    nested :rep_perm do
      property :representant_permanent_nom, as: :nom
      property :representant_permanent_nom_usage, as: :nom_usage
      property :representant_permanent_prenoms, as: :prenom
      property :representant_permanent_date_naissance, as: :dat_naiss
      property :representant_permanent_ville_naissance, as: :lieu_naiss
      property :representant_permanent_pays_naissance, as: :pays_naiss
    end

    property :adresse_representant_permanent,
      as: :rep_perm,
      decorator: TribunalInstance::AdresseRepresentantPermanentRepresenter,
      class: TribunalInstance::AdresseRepresentantPermanent
  end
end
