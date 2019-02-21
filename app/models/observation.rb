class Observation < ApplicationRecord
  prepend ClearDataHelper

  belongs_to :dossier_entreprise
end
