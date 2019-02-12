class TribunalInstance::Representant < ApplicationRecord
  belongs_to :entreprise
  has_one :adresse_representant,           dependent: :destroy
  has_one :adresse_representant_permanent, dependent: :destroy
end
