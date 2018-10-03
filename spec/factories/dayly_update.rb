FactoryBot.define do
  factory :dayly_update do
    year { '2016' }
    month { '04' }
    day { '21' }
    files_path { '/not/here' }

    factory :dayly_update_with_pending_units, class: DaylyUpdate do
      after(:create) do |update|
        create_list(:dayly_update_unit, 3, status: 'PENDING', dayly_update: update)
      end
    end

    factory :dayly_update_with_one_loading_unit, class: DaylyUpdate do
      after(:create) do |update|
        create_list(:dayly_update_unit, 3, status: 'PENDING', dayly_update: update)
        create(:dayly_update_unit, status: 'LOADING', dayly_update: update)
      end
    end

    factory :dayly_update_with_one_error_unit, class: DaylyUpdate do
      after(:create) do |update|
        create_list(:dayly_update_unit, 3, status: 'PENDING', dayly_update: update)
        create(:dayly_update_unit, status: 'ERROR', dayly_update: update)
      end
    end

    factory :dayly_update_with_completed_units, class: DaylyUpdate do
      after(:create) do |update|
        create_list(:dayly_update_unit, 3, status: 'COMPLETED', dayly_update: update)
      end
    end
  end

  factory :dayly_update_tribunal_commerce, parent: :dayly_update, class: DaylyUpdateTribunalCommerce do
    type { 'DaylyUpdateTribunalCommerce' }
  end
end
