FactoryBot.define do
  factory :stock do
    year { '2017' }
    month { '10' }
    day { '23' }
    files_path { '/not/here' }
  end

  factory :stock_tribunal_commerce, parent: :stock, class: StockTribunalCommerce do
    type { 'StockTribunalCommerce' }

    factory :stock_with_pending_units, class: Stock do
      after(:create) do |stock|
        create_list(:stock_unit, 3, status: 'PENDING', stock: stock)
      end
    end

    factory :stock_with_one_loading_unit, class: Stock do
      after(:create) do |stock|
        create_list(:stock_unit, 3, status: 'PENDING', stock: stock)
        create(:stock_unit, status: 'LOADING', stock: stock)
      end
    end

    factory :stock_with_one_error_unit, class: Stock do
      after(:create) do |stock|
        create_list(:stock_unit, 3, status: 'PENDING', stock: stock)
        create(:stock_unit, status: 'ERROR', stock: stock)
      end
    end

    factory :stock_with_completed_units, class: Stock do
      after(:create) do |stock|
        create_list(:stock_unit, 3, status: 'COMPLETED', stock: stock)
      end
    end
  end
end
