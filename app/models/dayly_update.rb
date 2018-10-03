class DaylyUpdate < ApplicationRecord
  has_many :dayly_update_units

  def self.current
    collection = self.order(year: :desc, month: :desc, day: :desc).limit(1)
    collection.first
  end

  def status
    child_status = dayly_update_units_status

    if child_status.all? { |status| status == 'PENDING' }
      return 'PENDING'

    elsif child_status.all? { |status| status == 'COMPLETED' }
      return 'COMPLETED'

    elsif child_status.any? { |status| status == 'LOADING' }
      return 'LOADING'

    elsif child_status.any? { |status| status == 'ERROR' }
      return 'ERROR'
    end
  end

  def dayly_update_units_status
    self.dayly_update_units.pluck(:status)
  end
end
