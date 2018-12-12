require 'colorize'

namespace :titmc do
  desc 'Start the import of the latest Titmc Stock'
  task import_stocks: :prepare_env do
    operation = DataSource::Stock::TribunalInstance::Operation::Load
      .call(logger: Logger.new(STDOUT))
    puts "Success: #{operation.success?}".blue
  end

  desc 'Restart ALL stock units jobs'
  task restart_jobs: :prepare_env do
    puts "Current Stock: #{current_stock.files_path}".blue

    current_stock.stock_units.each do |stock_unit|
      filename = Pathname.new(stock_unit.file_path).basename
      puts "Job id: #{stock_unit.id} filename: #{filename} current status: #{stock_unit.status}"

      ImportTitmcStockUnitJob.perform_now(
        stock_unit.id,
        Logger.new(STDOUT)
      )

      stock_unit.reload
      puts "New status: #{stock_unit.status}"

    end

    puts "#{current_stock.stock_units.count} jobs enqueued".green
  end

  desc 'Restart ONE pending stock unit job'
  task :restart_one_greffe, [:code_greffe] => :prepare_env do |_, args|
    if args[:code_greffe].nil?
      units = [current_stock.stock_units.first]
    else
      units = current_stock.stock_units.where code_greffe: args[:code_greffe]
    end

    units.each do |unit|
      puts "Code greffe: #{unit.code_greffe.green}"

      puts "Current status: #{unit.status}".yellow

      ImportTitmcStockUnitJob.perform_now(
        unit.id,
        Logger.new(STDOUT)
      )

      unit.reload
      puts "New status: #{unit.status}".yellow
    end
  end

  desc 'Show current import status'
  task status: :environment do
    puts "Current stock status: #{current_stock.status.yellow}"

    success_count = 0
    current_stock.stock_units.each do |unit|
      puts "Unit: #{unit.code_greffe} is #{unit.status.yellow}" if unit.status == 'PENDING'
      puts "Unit: #{unit.code_greffe} is #{unit.status.red}"    if unit.status == 'ERROR'
      success_count += 1 if unit.status == 'COMPLETED'
    end

    puts "#{success_count} successful import".green
  end

  task :prepare_env, [:queue_adapter] => :environment do |_, args|
    # let's use :inline here (override with rake param)
    queue_adapter = args[:queue_adapter] || :inline
    Rails.application.config.active_job.queue_adapter = queue_adapter
    puts "Using queue adapter: #{queue_adapter.to_s.blue}"

    Rake::Task['sidekiq:clear_queue'].invoke 'titmc_stock'
  end

  private

  def current_stock
    @current_stock ||= StockTribunalInstance.current
  end
end
