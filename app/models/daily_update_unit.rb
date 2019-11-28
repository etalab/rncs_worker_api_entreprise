class DailyUpdateUnit < ApplicationRecord
  belongs_to :daily_update

  def logger_for_import
    filename = "import_#{reference}.log"
    file_path = Rails.root.join('log', filename).to_s
    Logger.new(file_path)
  end
end
