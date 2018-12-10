FactoryBot.define do
  factory :stock_unit do
    code_greffe { '0123' }
    number { 1 }
    file_path { '/temp' }
    status { 'PENDING' }
    stock

    factory :stock_unit_wildcard do
      file_path { '/temp/test_*' }
    end
  end
end
