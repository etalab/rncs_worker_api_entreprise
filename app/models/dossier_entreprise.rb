class DossierEntreprise < ApplicationRecord
  has_one :personne_morale
  has_one :personne_physique
  has_many :representants
  has_many :etablissements
  has_many :observations
end
