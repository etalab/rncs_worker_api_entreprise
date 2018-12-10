require 'rails_helper'

describe TribunalCommerce::DailyUpdateUnit::Operation::Load, :trb do
  let(:logger) { instance_double(Logger).as_null_object }
  let(:unit) { create(:daily_update_unit, files_path: fixture_path) }
  subject { described_class.call(daily_update_unit: unit, logger: logger) }

  context 'at the beginning' do
    it 'logs the daily update date that will be imported' do
      unit.daily_update.update_attributes(year: '2020', month: '10', day: '21')
      expect(logger).to receive(:info).with('START IMPORT OF UPDATE 2020-10-21')

      subject
    end
  end

  # spec/fixtures/tc/flux/2018/04/09/0110
  # ├── 21
  # ├── 22
  # ├── 23
  # └── 24
  #
  # The example folder contains 4 transmissions (from 21 to 24)
  context 'with a valid unit\'s folder content' do
    let(:fixture_path) { Rails.root.join('spec/fixtures/tc/flux/2018/04/09/0110') }

    context 'when the transmission imports successfuly' do
      before do |example|
        # Some tests need to setup calls to the dependency with more precision
        # than this "dumb" mock. So they need a way to disable this default hook
        mock_transmission_import_success unless example.metadata[:skip_before]
      end

      it { is_expected.to be_success }

      it 'fetches every transmissions in pipe' do
        transmissions = subject[:transmissions_paths]

        expect(transmissions).to contain_exactly(
          a_string_ending_with('/21'),
          a_string_ending_with('/22'),
          a_string_ending_with('/23'),
          a_string_ending_with('/24'),
        )
      end

      it 'logs when each transmission starts to import' do
        (21..24).each { |nb| expect(logger).to receive(:info).with("Starting to import transmission number #{nb}...") }

        subject
      end

      it 'imports each transmission in the right order', skip_before: true do
        expect_ordered_import_of_transmissions

        subject
      end

      it 'logs each transmission\'s import success' do
        (21..24).each { |nb| expect(logger).to receive(:info).with("Import of transmission number #{nb} is complete !") }

        subject
      end

      it 'logs the overall unit\'s import success' do
        expect(logger).to receive(:info)
          .with("Each transmission has been successfuly imported. The daily update is a success for greffe #{unit.code_greffe} !")

        subject
      end
    end

    context 'when one transmission fails to import' do
      before { fail_on_first_transmission }

      it { is_expected.to be_failure }

      it 'logs the transmission\'s import failure' do
        expect(logger).to receive(:error)
          .with('An error occured while importing transmission number 21. Aborting daily update unit import...')

        subject
      end

      it 'cancels import of the following transmissions' do
        ensure_import_is_cancel_for_transmissions(22, 23, 24)

        subject
      end
    end
  end

  context 'with an invalid unit\'s folder content' do
    it 'is failure'
    it 'logs'
  end

  def expect_ordered_import_of_transmissions
    (21..24).each do |transmission_number|
      expect(TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission)
        .to receive(:call)
        .with(files_path: a_string_ending_with("/#{transmission_number}"), logger: logger)
        .and_return(trb_result_success)
        .ordered # fails if calls are out of order
    end
  end

  def ensure_import_is_cancel_for_transmissions(*transmissions)
    transmissions.each do |transmission|
      expect(TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission)
        .to_not receive(:call)
        .with(a_string_ending_with("/#{transmission}"), logger: logger)
    end
  end

  def mock_transmission_import_success
    expect(TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission)
      .to receive(:call)
      .and_return(trb_result_success)
      .exactly(4).times
  end

  def fail_on_first_transmission
    expect(TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission)
      .to receive(:call)
      .with(files_path: a_string_ending_with('/21'), logger: logger)
      .and_return(trb_result_failure)
  end
end
