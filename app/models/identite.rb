class Identite < ApplicationRecord
  belongs_to :identifiable, polymorphic: true
end
