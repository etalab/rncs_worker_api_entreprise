class Stock < ApplicationRecord
  has_many :stock_units, dependent: :destroy

  class << self
    def first_load?
      count.zero?
    end

    def current
      collection = order(year: :desc, month: :desc, day: :desc).limit(1)
      collection.first
    end
  end

  def date
    string_date = [year, month, day].join('/')
    Date.parse(string_date)
  end

  def newer?
    last_loaded_stock = self.class.current
    if last_loaded_stock.nil?
      true
    else
      compare = date <=> last_loaded_stock.date
      compare == 1
    end
  end

  # rubocop:disable Style/GuardClause
  def status
    child_status = stock_units_status

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
  # rubocop:enable Style/GuardClause

  def stock_units_status
    stock_units.pluck(:status)
  end
end
