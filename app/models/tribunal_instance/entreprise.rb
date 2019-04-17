class TribunalInstance::Entreprise < ApplicationRecord
  belongs_to :dossier_entreprise
  has_one :adresse_siege,          dependent: :destroy
  has_one :adresse_domiciliataire, dependent: :destroy
  has_one :adresse_dap,            dependent: :destroy
  has_many :etablissements,        dependent: :destroy
  has_many :representants,         dependent: :destroy
  has_many :observations,          dependent: :destroy
end
