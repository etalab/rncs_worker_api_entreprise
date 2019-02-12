class TribunalInstance::Etablissement < ApplicationRecord
  belongs_to :entreprise
  has_one :adresse, dependent: :destroy
end
