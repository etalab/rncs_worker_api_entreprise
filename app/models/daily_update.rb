class DailyUpdate < ApplicationRecord
  has_many :daily_update_units

  class << self
    def current
      collection = where(proceeded: true).order(year: :desc, month: :desc, day: :desc, partial_stock: :asc).limit(1)
      collection.first
    end

    def last_completed
      where(proceeded: true)
        .order(year: :desc, month: :desc, day: :desc, partial_stock: :asc)
        .find { |e| e.status == 'COMPLETED' }
    end

    def queued_updates?
      collection = where(proceeded: false)
      !collection.empty?
    end

    def next_in_queue
      collection = where(proceeded: false).order(year: :asc, month: :asc, day: :asc, partial_stock: :desc).limit(1)
      collection.first
    end
  end

  def date
    string_date = [year, month, day].join('/')
    Date.parse(string_date)
  end

  def newer?(telltale_date)
    date > telltale_date
  end

  def older?(telltale_date)
    !newer?(telltale_date)
  end

  # rubocop:disable Metrics/PerceivedComplexity, Style/GuardClause, Metrics/CyclomaticComplexity
  def status
    child_status = daily_update_units_status

    if child_status.empty?
      return 'QUEUED'

    elsif child_status.all? { |status| status == 'PENDING' }
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
  # rubocop:enable Metrics/PerceivedComplexity, Style/GuardClause, Metrics/CyclomaticComplexity

  def daily_update_units_status
    daily_update_units.pluck(:status)
  end
end
