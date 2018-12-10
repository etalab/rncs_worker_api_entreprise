require 'colorize'

namespace :sidekiq do
  desc 'clear Sidekiq queues, all or only one (ie: rake sidekiq:clear_queue[:titmc_stock])'
  task :clear_queue, [:queue_name] => :environment do |t, args|
    case args[:queue_name]
    when nil
      display_help
    when 'all'
      clear_all_queues
    else
      clear_one_queue args[:queue_name]
    end
  end

  def display_help
    queue_names = Sidekiq::Queue.all.map { |q|
      q.name.slice! queue_prefix
      q.name
    }.join(', ')

    puts "It requires an argument: all, #{queue_names}".red
  end

  def clear_all_queues
      Sidekiq::Queue.all.each do |q|
        q.clear
        puts "Queue #{q.name} cleared".green
      end
  end

  def clear_one_queue(name)
    fullname = queue_prefix + name
    queue = Sidekiq::Queue.new(fullname)
    nb_jobs = queue.count
    queue.clear
    puts "Queue #{queue.name} cleared (#{nb_jobs} jobs cancelled)".green
  end

  def queue_prefix
    "rncs_worker_api_entreprise_#{Rails.env}_"
  end
end
