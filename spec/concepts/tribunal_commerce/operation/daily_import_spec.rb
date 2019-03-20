require 'rails_helper'

describe TribunalCommerce::Operation::DailyImport, :trb do
  let(:logger) { instance_spy(Logger) }

  subject { described_class.call(logger: logger) }

  describe 'logger dependency' do
    it 'defaults to Rails.logger' do
      logger = described_class.call[:logger]

      expect(logger).to eq(Rails.logger)
    end
  end

  it 'logs the import starts' do
    subject

    expect(logger).to have_received(:info).with('Starting daily import...')
  end

  context 'when new updates are found' do
    before do
      allow(TribunalCommerce::DailyUpdate::Operation::Load)
        .to receive(:call)
        .with(delay: 1)
        .and_return(trb_result_success)
    end

    it 'calls the import operation' do
      expect(TribunalCommerce::DailyUpdate::Operation::Import)
        .to receive(:call)
        .and_return(trb_result_success)

      subject
    end

    it 'logs if the import fail' do
      allow(TribunalCommerce::DailyUpdate::Operation::Import)
        .to receive(:call)
        .and_return(trb_result_failure)
      subject

      expect(logger).to have_received(:error).with('An error occured during import. Aborting...')
    end
  end

  context 'when no updates are available' do
    before do
      allow(TribunalCommerce::DailyUpdate::Operation::Load)
        .to receive(:call)
        .and_return(trb_result_failure)
    end

    it 'does not call the import operation' do
      expect(TribunalCommerce::DailyUpdate::Operation::Import)
        .to_not receive(:call)

      subject
    end

    it 'logs no newer updates have been fetched' do
      subject

      expect(logger).to have_received(:error)
        .with('No updates have been added to the queue, aborting import...')
    end
  end
end
