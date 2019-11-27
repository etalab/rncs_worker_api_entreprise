class StockUnit < ApplicationRecord
  belongs_to :stock

  def logger_for_import
    Logger.new log_file_path
  end

  private

  def log_file_path
    Rails.root.join('log', log_filename).to_s
  end

  def log_filename
    "import_#{code_greffe}.log"
  end

  def stock_date
    [stock.year, stock.month, stock.day].join('')
  end

  def formatted_current_datetime
    Time.now.strftime('%Y_%m_%d__%H_%M_%S')
  end
end
