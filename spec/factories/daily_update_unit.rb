FactoryBot.define do
  factory :daily_update_unit do
    reference { 'reference_document' }
    num_transmission { 1 }
    files_path { '/temp' }
    status { 'PENDING' }
    daily_update
  end
end
