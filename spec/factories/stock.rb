FactoryBot.define do
  factory :stock do
    year { '2017' }
    month { '10' }
    day { '23' }
    files_path { '/not/here' }

    # TITMC
    factory :stock_titmc, class: StockTribunalInstance do
      factory :stock_titmc_with_pending_units do
        after :create do |stock|
          create_list(:stock_unit_titmc, 3, status: 'PENDING', stock: stock)
        end
      end

      factory :stock_titmc_with_one_loading_unit do
        after(:create) do |stock|
          create_list(:stock_unit_titmc, 3, status: 'PENDING', stock: stock)
          create(:stock_unit_titmc, status: 'LOADING', stock: stock)
        end
      end

      factory :stock_titmc_with_one_error_unit do
        after(:create) do |stock|
          create_list(:stock_unit_titmc, 3, status: 'PENDING', stock: stock)
          create(:stock_unit_titmc, status: 'ERROR', stock: stock)
        end
      end

      factory :stock_titmc_with_completed_units do
        after(:create) do |stock|
          create_list(:stock_unit_titmc, 3, status: 'COMPLETED', stock: stock)
        end
      end
    end

    # TC
    factory :stock_tc, class: StockTribunalCommerce do
      factory :stock_tc_with_pending_units do
        after(:create) do |stock|
          create_list(:stock_unit, 3, status: 'PENDING', stock: stock)
        end
      end

      factory :stock_tc_with_one_loading_unit do
        after(:create) do |stock|
          create_list(:stock_unit, 3, status: 'PENDING', stock: stock)
          create(:stock_unit, status: 'LOADING', stock: stock)
        end
      end

      factory :stock_tc_with_one_error_unit do
        after(:create) do |stock|
          create_list(:stock_unit, 3, status: 'PENDING', stock: stock)
          create(:stock_unit, status: 'ERROR', stock: stock)
        end
      end

      factory :stock_tc_with_completed_units do
        after(:create) do |stock|
          create_list(:stock_unit, 3, status: 'COMPLETED', stock: stock)
        end
      end
    end
  end
end
