class Adresse < ApplicationRecord
  belongs_to :addressable, polymorphic: true
end
