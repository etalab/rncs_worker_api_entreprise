require 'rails_helper'

describe ImportTitmcStockUnitJob, :trb do
  subject { described_class.perform_now(id) }

  context 'when stock unit is found' do
    let(:stock_unit) { create :stock_unit_wildcard, status: 'PENDING' }
    let(:id) { stock_unit.id }

    describe 'success' do
      it 'calls the operation' do
        expect(DataSource::Stock::TribunalInstance::Unit::Operation::Load)
          .to receive(:call)
          .with(stock_unit: stock_unit)
          .and_return(trb_result_success)

        subject
      end

      it 'set status to COMPLETED' do
        allow(DataSource::Stock::TribunalInstance::Unit::Operation::Load)
          .to receive(:call)
          .with(stock_unit: stock_unit)
          .and_return(trb_result_success)

        subject
        stock_unit.reload

        expect(stock_unit.status).to eq 'COMPLETED'
      end
    end

    describe 'failure' do
      it 'rollbacks database' do
        allow(DataSource::Stock::TribunalInstance::Unit::Operation::Load)
          .to receive(:call)
          .with(stock_unit: stock_unit)
          .and_wrap_original {
            create :stock_unit, status: 'GHOST'
            trb_result_failure
        }

        subject

        ghost = StockUnit.where(status: 'GHOST')
        expect(ghost).to be_empty
      end

      it 'set status to ERROR' do
        allow(DataSource::Stock::TribunalInstance::Unit::Operation::Load)
          .to receive(:call)
          .with(stock_unit: stock_unit)
          .and_return(trb_result_failure)

        subject
        stock_unit.reload

        expect(stock_unit.status).to eq 'ERROR'
      end
    end
  end

  context 'when stock unit is not found' do
    let(:id) { 1234 }

    it 'does not call the operation' do
      expect(DataSource::Stock::TribunalInstance::Unit::Operation::Load)
        .not_to receive(:call)
      subject
    end

    it 'logs an error' do
      expect(Rails.logger).to receive(:error).with "Couldn't find StockUnit with 'id'=1234"
      subject
    end
  end
end
