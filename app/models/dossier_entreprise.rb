class DossierEntreprise < ApplicationRecord
  has_one :personne_morale
  has_one :personne_physique
  has_many :representants
  has_many :etablissements
  has_many :observations

  # this will not warn about multiple SIE/SEP on this dossier / siren
  def siege_social
    @siege_social ||= etablissements.find_by(type_etablissement: 'SIE') || etablissements.find_by(type_etablissement: 'SEP')
  end

  # this will not warn about multiple PRI/SEP on this dossier / siren
  def etablissement_principal
    @etablissement_principal ||= etablissements.find_by(type_etablissement: 'PRI') || etablissements.find_by(type_etablissement: 'SEP')
  end
end
