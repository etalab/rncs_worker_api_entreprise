class DailyUpdate < ApplicationRecord
  has_many :daily_update_units

  def self.current
    collection = self.order(year: :desc, month: :desc, day: :desc).limit(1)
    collection.first
  end

  def date
    string_date = [year, month, day].join('/')
    Date.parse(string_date)
  end

  def newer?(telltale_date)
    self.date > telltale_date
  end

  def status
    child_status = daily_update_units_status

    if child_status.all? { |status| status == 'PENDING' }
      return 'PENDING'

    elsif child_status.all? { |status| status == 'COMPLETED' }
      return 'COMPLETED'

    elsif child_status.any? { |status| status == 'LOADING' }
      return 'LOADING'

    elsif child_status.any? { |status| status == 'ERROR' }
      return 'ERROR'

    elsif child_status.empty?
      return 'PENDING'
    end
  end

  def daily_update_units_status
    self.daily_update_units.pluck(:status)
  end
end
