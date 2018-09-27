class Stock < ApplicationRecord
  has_many :stock_units

  class << self
    def first_load?
      self.count == 0
    end

    def current
      collection = self.order(year: :desc, month: :desc, day: :desc).limit(1)
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

  # TODO make it a calculated value based on associated stock units status
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

  def stock_units_status
    self.stock_units.pluck(:status)
  end
end
