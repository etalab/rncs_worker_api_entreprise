class DailyUpdateUnit < ApplicationRecord
  belongs_to :daily_update

  def logger_for_import
    filename = "import_#{reference}.log"
    file_path = Rails.root.join('log', filename).to_s
    Logger.new(file_path)
  end

  private

  def formated_daily_update_date
    [daily_update.year, daily_update.month, daily_update.day].join('')
  end

  def formated_current_time
    Time.now.strftime('%Y_%m_%d')
  end
end
