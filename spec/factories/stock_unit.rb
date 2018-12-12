FactoryBot.define do
  factory :stock_unit do
    code_greffe { '0123' }
    number { 1 }
    file_path { '/temp' }
    status { 'PENDING' }
    stock

    factory :stock_unit_wildcard do
      file_path do
          Rails.root.join(
            'spec', 'fixtures', 'titmc', 'stock', '2018', '05', '05',
            '9721_S1_20180505_lot*.zip'
          ).to_s
      end
    end
  end
end
