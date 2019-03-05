require 'colorize'

namespace :titmc do
  namespace :flux do
    desc 'Start import of remaning daily updates'
    task :load, [:limit_date] => :environment do |_, args|
      puts "Date limite d'import #{args[:limit_date].yellow}"

      operation = TribunalInstance::DailyUpdate::Operation::Load.call(
        limit_date: args[:limit_date],
        logger: Logger.new(STDOUT)
      )
      puts "Operation status: #{operation.success?}".blue
    end

    desc 'Give the status of the latest daily update'
    task status: :environment do
      latest_update = DailyUpdateTribunalInstance.current
      puts "#{latest_update.date.to_s.green}, proceeded: #{latest_update.proceeded.to_s.green}, status: #{latest_update.status.green}"

      status_count = latest_update
        .daily_update_units
        .inject(Hash.new(0)) { |hash, unit| hash[unit.status] += 1 ; hash }

      status_count.each do |status, count|
        puts "#{status}: #{count}"
      end

      puts "#{DailyUpdateTribunalInstance.where(proceeded: false).count} updates in queue"
    end
  end
end
