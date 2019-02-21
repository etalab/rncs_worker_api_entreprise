class Etablissement < ApplicationRecord
  prepend ClearDataHelper

  belongs_to :dossier_entreprise
end
