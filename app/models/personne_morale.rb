class PersonneMorale < ApplicationRecord
  include CleanDataHelper

  belongs_to :dossier_entreprise
end
