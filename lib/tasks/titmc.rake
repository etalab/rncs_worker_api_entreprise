require 'colorize'

namespace :titmc do
  desc 'Start the import of the latest Titmc Stock'
  task import_stocks: :environment do
    puts 'Operations log will be done in log/stock/*.log not in STDOUT'.yellow
    operation = TribunalInstance::Stock::Operation::Load
      .call(logger: Logger.new(STDOUT))
    puts "Success: #{operation.success?}".blue
  end

  desc 'Enqueue non-completed jobs'
  task enqueue_jobs: :environment do
    Rails.application.config.active_job.queue_adapter = :sidekiq
    puts "Current Stock: #{current_stock.files_path}".blue

    non_completed_units = current_stock.stock_units.select { |u| u.status != 'COMPLETED' }

    non_completed_units.each do |stock_unit|
      restart_import(stock_unit) do |stock_unit_id|
        ImportTitmcStockUnitJob.perform_later(stock_unit_id)
      end
    end
  end

  desc 'Restart ALL stock units jobs (inline)'
  task restart_jobs: :prepare_env do
    current_stock.stock_units.each do |stock_unit|
      restart_import(stock_unit) do |stock_unit_id|
        ImportTitmcStockUnitJob.perform_now(
          stock_unit_id,
          Logger.new(STDOUT)
        )
      end
    end
  end

  desc 'Restart ONE pending stock unit job (escape \[ in command line for zsh)'
  task :restart_one_greffe, [:code_greffe] => :prepare_env do |_, args|
    if args[:code_greffe].nil?
      units = [current_stock.stock_units.first]
    else
      units = current_stock.stock_units.where code_greffe: args[:code_greffe]
    end

    units.each do |stock_unit|
      restart_import(stock_unit) do |stock_unit_id|
        ImportTitmcStockUnitJob.perform_now(
          stock_unit_id,
          Logger.new(STDOUT)
        )
      end
    end
  end

  desc 'Show current import status'
  task status: :environment do
    puts "Current stock status: #{current_stock.status.yellow}"

    success_count = 0
    units = current_stock.stock_units.sort_by(&:code_greffe)
    units.each do |unit|
      case unit.status
      when 'PENDING'
        unit_status = unit.status.yellow
      when 'LOADING'
        unit_status = unit.status.blue
      when 'ERROR'
        unit_status = unit.status.red
      when 'COMPLETED'
        unit_status = unit.status.green
      end

      puts "Unit: #{unit.code_greffe} is #{unit_status}"
      success_count += 1 if unit.status == 'COMPLETED'
    end

    puts "#{success_count} successful import".green
  end

  task prepare_env: :environment do |_, args|
    puts "Current Stock: #{current_stock.files_path}".blue
    Rails.application.config.active_job.queue_adapter = :inline
  end

  private

  def current_stock
    @current_stock ||= StockTribunalInstance.current
  end

  def restart_import(stock_unit)
    filename = Pathname.new(stock_unit.file_path).basename
    puts "Job id: #{stock_unit.id} filename: #{filename} current status: #{stock_unit.status}"

    yield stock_unit.id

    stock_unit.reload
    puts "New status: #{stock_unit.status}"
  end
end
