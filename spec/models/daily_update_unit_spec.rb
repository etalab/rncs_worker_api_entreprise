require 'rails_helper'

describe DailyUpdateUnit do
  describe 'database schema' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference).of_type(:string) }
    it { is_expected.to have_db_column(:files_path).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
    it { is_expected.to have_db_column(:num_transmission).of_type(:integer) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

    it { is_expected.to belong_to(:daily_update) }
  end

  describe '#logger_for_import' do
    let!(:unit) { create(:daily_update_unit) }

    subject { unit.logger_for_import }

    it 'is a logger instance' do
      expect(subject).to be_an_instance_of(Logger)
    end

    it 'has a valid filename : import_<code_greffe>.log' do
      code_greffe = unit.reference
      expected_log_filename = Rails.root.join("log/import_#{code_greffe}.log").to_s

      expect(Logger).to receive(:new).with(expected_log_filename)

      subject
    end

    after { FileUtils.rm_rf(Rails.root.join('log', "import_#{unit.reference}.log")) }
  end
end
