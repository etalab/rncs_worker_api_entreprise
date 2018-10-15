require 'rails_helper'

describe TribunalCommerce::DailyUpdateUnit::Operation::Load do
  let(:unit) { create(:daily_update_unit, files_path: fixture_path) }
  subject { described_class.call(daily_update_unit: unit) }

  # spec/fixtures/tc/flux/2018/04/09/0110
  # ├── 21
  # ├── 22
  # ├── 23
  # └── 24
  #
  # The example folder contains 4 transmissions (from 21 to 24)
  context 'with a valid unit\'s folder content' do
    let(:fixture_path) { Rails.root.join('spec/fixtures/tc/flux/2018/04/09/0110') }

    it 'fetches every transmissions in pipe' do
      transmissions = subject[:transmissions_paths]

      expect(transmissions).to contain_exactly(
        a_string_ending_with('/21'),
        a_string_ending_with('/22'),
        a_string_ending_with('/23'),
        a_string_ending_with('/24'),
      )
    end

    it 'imports each transmission in the right order' do
      # calls need to appear in the following order
      expect_import_of_transmission(21)
      expect_import_of_transmission(22)
      expect_import_of_transmission(23)
      expect_import_of_transmission(24)

      subject
    end

    it 'logs when transmission\'s import starts'

    context 'when a transmission\'s import is complete' do
      it 'logs'
    end

    context 'when one transmission fails to import' do
      before do
        transmission_result = instance_double(
          Trailblazer::Operation::Railway::Result,
          success?: false,
          failure?: true
        )
        expect(TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission)
          .to receive(:call)
          .with(files_path: a_string_ending_with('/21'))
          .and_return(transmission_result)
      end

      it { is_expected.to be_failure }

      it 'logs'

      it 'cancels import of the following transmissions' do
        ensure_import_is_cancel_for_transmission(22)
        ensure_import_is_cancel_for_transmission(23)
        ensure_import_is_cancel_for_transmission(24)

        subject
      end
    end

    context 'when each transmission is fully imported' do
      it { is_expected.to be_success }

      it 'logs'
    end
  end

  context 'with an invalid unit\'s folder content' do
    it 'is failure'
    it 'logs'
  end


  def expect_import_of_transmission(nb)
    op_result = instance_double(
      Trailblazer::Operation::Railway::Result,
      success?: true,
      failure?: false
    )
    expect(TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission)
      .to receive(:call)
      .with(files_path: a_string_ending_with("/#{nb}"))
      .and_return(op_result)
      .ordered
  end

  def ensure_import_is_cancel_for_transmission(nb)
    expect(TribunalCommerce::DailyUpdateUnit::Operation::ImportTransmission)
      .to_not receive(:call)
      .with(a_string_ending_with("/#{nb}"))
  end
end
