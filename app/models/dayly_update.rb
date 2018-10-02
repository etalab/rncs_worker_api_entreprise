class DaylyUpdate < ApplicationRecord
  def self.current
    collection = self.order(year: :desc, month: :desc, day: :desc).limit(1)
    collection.first
  end
end
