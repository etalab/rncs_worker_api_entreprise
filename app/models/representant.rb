class Representant < ApplicationRecord
  include CleanDataHelper

  belongs_to :dossier_entreprise
end
