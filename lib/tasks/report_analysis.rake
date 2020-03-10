require 'csv'

namespace :report do
  desc 'Generate a CSV report of invalid data'
  task analysis: :environment do
    write_headers
    job_count = 0
    DossierEntreprise.find_in_batches(batch_size: BATCH_SIZE) do |dossiers|
      ids = dossiers.select { |d| d.type_inscription == 'P' }.map(&:id)
      ValidateDossierJob.perform_later ids

      job_count += 1
      break if job_count > JOB_LIMIT
    end
  end

  BATCH_SIZE = 50
  JOB_LIMIT = 50

  def write_headers
    CSV.open(ValidateDossierJob::FILENAME, 'w') do |csv|
      csv << ValidateDossierJob::HEADERS
    end
  end
end
