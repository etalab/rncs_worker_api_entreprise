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
    let(:unit) do
      temp = create(:daily_update, year: '2020', month: '07', day: '29')
      create(:daily_update_unit, reference: 'ref_doc', daily_update: temp)
    end

    subject { unit.logger_for_import }

    it 'is a logger instance' do
      expect(subject).to be_an_instance_of(Logger)
    end

    it 'has a valid filename : <code_greffe>__<current_date>.log' do
      mock_logger = double(Logger)
      current_time = Time.now
      Timecop.freeze(current_time)

      format_time = current_time.strftime('%Y_%m_%d')
      expected_log_filename = Rails.root.join("log/flux/ref_doc__#{format_time}.log").to_s
      expect(Logger).to receive(:new).with(expected_log_filename).and_return(mock_logger)

      expect(subject).to eq(mock_logger)
      Timecop.return
    end
  end

  # TODO: not sure I need this since the logger is mocked
  after { FileUtils.rm_rf(Dir.glob(Rails.root.join('log/flux/*'))) }
end
