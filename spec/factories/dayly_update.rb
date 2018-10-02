FactoryBot.define do
  factory :dayly_update do
    year { '2016' }
    month { '04' }
    day { '21' }
    files_path { '/not/here' }
  end
end
