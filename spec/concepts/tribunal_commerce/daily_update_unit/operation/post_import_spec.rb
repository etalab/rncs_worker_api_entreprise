require 'rails_helper'

describe TribunalCommerce::DailyUpdateUnit::Operation::PostImport do
  subject { described_class.call(daily_update_unit: unit) }

  context 'when the daily update is fully imported' do
    let(:unit) do
      completed_update = create(:daily_update_with_completed_units)
      completed_update.daily_update_units.take
    end

    it 'imports the next daily update in queue' do
      pending 'need a way to stub nested operation'
      expect(TribunalCommerce::DailyUpdate::Operation::Import)
        .to receive(:call)
    end

    it 'logs'
  end

  context 'when the daily update is not completed' do
    it 'does nothing'
  end
end
