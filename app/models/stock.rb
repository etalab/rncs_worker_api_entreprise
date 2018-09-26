class Stock < ApplicationRecord
  has_many :stock_units

  class << self
    def first_load?
      self.count == 0
    end

    def current
      self.last
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
      date <=> last_loaded_stock.date
    end
  end

  # TODO make it a calculated value based on associated stock units status
  def status
    'PENDING'
  end
end
