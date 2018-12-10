FactoryBot.define do
  factory :stock_unit do
    code_greffe { '0123' }
    number { 1 }
    file_path { '/temp' }
    status { 'PENDING' }
    stock
  end
end
