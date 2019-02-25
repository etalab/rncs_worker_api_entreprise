class PersonnePhysique < ApplicationRecord
  include ClearDataHelper

  belongs_to :dossier_entreprise
end
