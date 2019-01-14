FactoryBot.define do
  factory :daily_update do
    year { '2016' }
    month { '04' }
    day { '21' }
    files_path { '/not/here' }
    proceeded { true }
    partial_stock { false }

    factory :daily_update_tribunal_commerce, parent: :daily_update, class: DailyUpdateTribunalCommerce do
      type { 'DailyUpdateTribunalCommerce' }

      factory :daily_update_with_pending_units, class: DailyUpdate do
        after(:create) do |update|
          create_list(:daily_update_unit, 3, status: 'PENDING', daily_update: update)
        end
      end

      factory :daily_update_with_one_loading_unit, class: DailyUpdate do
        after(:create) do |update|
          create_list(:daily_update_unit, 3, status: 'PENDING', daily_update: update)
          create(:daily_update_unit, status: 'LOADING', daily_update: update)
        end
      end

      factory :daily_update_with_one_error_unit, class: DailyUpdate do
        after(:create) do |update|
          create_list(:daily_update_unit, 3, status: 'PENDING', daily_update: update)
          create(:daily_update_unit, status: 'ERROR', daily_update: update)
        end
      end

      factory :daily_update_with_completed_units, class: DailyUpdate do
        after(:create) do |update|
          create_list(:daily_update_unit, 3, status: 'COMPLETED', daily_update: update)
        end
      end
    end
  end
end
