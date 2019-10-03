require 'colorize'

namespace :sidekiq do
  desc 'Display status for queues'
  task status: :environment do
    Sidekiq::Queue.all.each do |q|
      puts "Queue: #{q.name.blue} has #{q.count.to_s.blue} jobs enqueued"
    end
  end

  desc 'clear Sidekiq queues, all or only one (ie: rake sidekiq:clear_queue[:titmc_stock])'
  task :clear_queue, [:queue_name] => :environment do |_, args|
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
    queue_names = Sidekiq::Queue.all.map do |q|
      q.name.slice! queue_prefix
      q.name
    end.join(', ')

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
