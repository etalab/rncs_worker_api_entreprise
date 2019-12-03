require 'rails_helper'

describe StockUnit do
  describe 'database schema' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:code_greffe).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
    it { is_expected.to have_db_column(:number).of_type(:integer) }
    it { is_expected.to have_db_column(:file_path).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

    it { is_expected.to belong_to(:stock) }
  end

  describe '#logger_for_import' do
    let!(:unit) { create(:stock_unit) }

    subject { unit.logger_for_import }

    it { is_expected.to be_a(Logger) }

    it 'has a valid filename: import_<code_greffe>.log' do
      code_greffe = unit.code_greffe
      exptected_log_file = Rails.root.join("log/import_#{code_greffe}.log").to_s

      expect(Logger)
        .to receive(:new)
        .with(exptected_log_file)

      subject
    end

    after { FileUtils.rm_rf(Rails.root.join('log', "import_#{unit.code_greffe}.log")) }
  end
end
