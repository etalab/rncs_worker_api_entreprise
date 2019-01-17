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
    subject { create(:stock_unit).logger_for_import }

    it { is_expected.to be_a Logger }

    it 'has a valid filename' do
      mock_logger = double Logger
      current_time = Time.now
      Timecop.freeze current_time

      format_time = current_time.strftime '%Y_%m_%d__%H_%M_%S'
      exptected_log_file = Rails.root.join(
        'log', 'stock',
        "20171023__0123__1__#{format_time}.log").to_s

      expect(Logger)
        .to receive(:new)
        .with(exptected_log_file)
        .and_return(mock_logger)

      subject
    end
  end
end
