require 'colorize'
require 'csv'

namespace :report do
  desc 'Generate a CSV report of invalid data'
  task analysis: :environment do
    write_headers

    puts "Loading jobs by batches #{BATCH_SIZE}".green
    Whirly.start spinner: 'random_dots', status: 'Enqueuing jobs' do
      enqueue_jobs
    end

    puts 'All jobs loaded'.green
  end

  BATCH_SIZE = 100_000
  BATCH_LIMIT = 1

  def enqueue_jobs
    batch_count = 0
    DossierEntreprise.find_in_batches(batch_size: BATCH_SIZE) do |dossiers|
      dossiers.select! { |d| d.type_inscription == 'P' }
      greffe_groups = dossiers.group_by(&:code_greffe)

      greffe_groups.each do |code_greffe, dossiers_of_greffe|
        ids = dossiers_of_greffe.map(&:id)
        ValidateDossierJob.perform_later code_greffe, ids
      end

      batch_count += 1
      break if batch_count > BATCH_LIMIT
    end
  end

  def write_headers
    puts 'Re-creating report files...'.yellow
    codes_greffes = DossierEntreprise.distinct.pluck(:code_greffe)

    codes_greffes.each do |code_greffe|
      CSV.open(ValidateDossierJob::filename(code_greffe), 'w') do |csv|
        csv << ValidateDossierJob::HEADERS
      end
    end
  end
end
