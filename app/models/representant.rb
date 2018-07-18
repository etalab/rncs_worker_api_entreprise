class Representant < ApplicationRecord
  belongs_to :entreprise
  has_one :identite, as: :identifiable
  has_one :representant_permanent_identite, as: :identifiable
  has_one :conjoint_collaborateur_identite, as: :identifiable
  has_one :adresse, as: :addressable
  has_one :representant_permanent_adresse, as: :addressable
end
