FactoryBot.define do
  factory :stock do
    year { '2017' }
    month { '10' }
    day { '23' }
    files_path { '/not/here' }
  end

  factory :stock_tribunal_commerce, parent: :stock, class: StockTribunalCommerce do
    type { 'StockTribunalCommerce' }
  end
end
