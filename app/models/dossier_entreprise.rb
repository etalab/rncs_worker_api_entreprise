class DossierEntreprise < ApplicationRecord
  has_one :personne_morale
  has_one :personne_physique
  has_many :representants
  has_many :etablissements
  has_many :observations

  def etablissement_principal
    etablissements.find_by(type_etablissement: 'PRI') || etablissements.find_by(type_etablissement: 'SEP')
  end
end
