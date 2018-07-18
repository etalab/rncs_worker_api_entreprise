class PersonnePhysique < ApplicationRecord
  has_one :identite, as: :identifiable
  has_one :adresse, as: :addressable
  has_one :dap_adresse, as: :addressable
  has_one :conjoint_collaborateur_identite, as: :identifiable
end
