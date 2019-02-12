FactoryBot.define do
  factory :stock_unit do
    code_greffe { '0123' }
    number { 1 }
    file_path { '/temp' }
    status { 'PENDING' }
    stock

    factory :stock_unit_titmc do
      code_greffe { '9721' }
      file_path do
        Rails.root.join(
          'spec', 'fixtures', 'titmc', 'stock', '2018', '05', '05',
          '9721_S1_20180505_lot*.zip'
        ).to_s
      end
    end

    factory :stock_unit_titmc_with_valid_zip do
      code_greffe { '9712' }
      file_path do
        Rails.root.join(
          'spec', 'fixtures', 'titmc', 'zip',
          '9712_S1_20180505_lot02.zip'
        ).to_s
      end
    end
  end
end
