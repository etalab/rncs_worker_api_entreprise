class Representant < ApplicationRecord
  include ClearDataHelper

  belongs_to :dossier_entreprise
end
