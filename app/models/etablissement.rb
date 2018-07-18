class Etablissement < ApplicationRecord
  belongs_to :entreprise
  has_one :adresse, as: :addressable
end
