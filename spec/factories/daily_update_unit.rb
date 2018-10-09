FactoryBot.define do
  factory :daily_update_unit do
    code_greffe { '0123' }
    num_transmission { 1 }
    files_path { '/temp' }
    status { 'PENDING' }
  end
end
