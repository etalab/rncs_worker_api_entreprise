require 'colorize'

namespace :titmc do
  desc 'Start the import of the latest Titmc Stock'
  task import_stocks: :environment do
    operation = DataSource::Stock::TribunalInstance::Operation::Load
      .call(logger: Logger.new(STDOUT))

    puts "Success: #{operation.success?}".blue
  end

  desc 'Restart PENDING stock units imports'
  task restart_jobs: :environment do
    queue_adapter = Rails.application.config.active_job.queue_adapter
    puts "Using queue adapter: #{queue_adapter}".blue

    Rake::Task['sidekiq:clear_queue'].invoke 'titmc_stock'

    current_stock = StockTribunalInstance.current
    puts "Current Stock: #{current_stock.files_path}".blue

    current_stock.stock_units.each do |stock_unit|
      ImportTitmcStockUnitJob.perform_later(stock_unit.id)
      filename = Pathname.new(stock_unit.file_path).basename
      puts "Job id: #{stock_unit.id} filename: #{filename}"
    end

    puts "#{current_stock.stock_units.count} jobs enqueued".green
  end

  desc 'Show current import status'
  task status: :environment do
    current_stock = StockTribunalInstance.current
    puts "Current stock status: #{current_stock.status.yellow}"

    success_count = 0
    current_stock.stock_units.each do |unit|
      puts "Unit: #{unit.id} is #{unit.status.yellow}" if unit.status == 'PENDING'
      puts "Unit: #{unit.id} is #{unit.status.red}"    if unit.status == 'ERROR'
      success_count += 1 if unit.status == 'COMPLETED'
    end

    puts "#{success_count} successful import".green
  end
end
