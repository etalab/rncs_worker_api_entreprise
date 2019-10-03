require 'rails_helper'

describe ImportTitmcStockUnitJob, :trb do
  subject { described_class.perform_now(id) }

  let(:logger) { instance_double(Logger).as_null_object }

  before do
    allow_any_instance_of(StockUnit)
      .to receive(:logger_for_import)
      .and_return(logger)
  end

  context 'when stock unit is found' do
    let(:stock_unit) { create :stock_unit_titmc, status: 'PENDING' }
    let(:id) { stock_unit.id }

    describe 'success' do
      it 'calls the operation' do
        expect(TribunalInstance::Stock::Unit::Operation::Load)
          .to receive(:call)
          .with(stock_unit: stock_unit, logger: logger)
          .and_return(trb_result_success)

        subject
      end

      describe 'when load operation succeed' do
        before do
          allow(TribunalInstance::Stock::Unit::Operation::Load)
            .to receive(:call)
            .with(stock_unit: stock_unit, logger: logger)
            .and_return(trb_result_success)
        end

        it 'set status to COMPLETED' do
          subject
          stock_unit.reload

          expect(stock_unit.status).to eq 'COMPLETED'
        end

        it 'calls PostImport with success' do
          expect(TribunalInstance::Stock::Operation::PostImport)
            .to receive(:call)
            .with(stock_unit: stock_unit, logger: logger)
            .and_return(trb_result_success)

          subject
        end

        it 'calls PostImport but fails when another stock unit is not completed' do
          create :stock_unit, status: 'PENDING', stock: stock_unit.stock
          expect(TribunalInstance::Stock::Operation::PostImport)
            .to receive(:call)
            .with(stock_unit: stock_unit, logger: logger)
            .and_return(trb_result_failure)

          subject
        end
      end
    end

    describe 'when operation Load fails' do
      it 'rollbacks database' do
        # rubocop:disable Lint/AmbiguousBlockAssociation
        allow(TribunalInstance::Stock::Unit::Operation::Load)
          .to receive(:call)
            .with(stock_unit: stock_unit, logger: logger)
            .and_wrap_original {
              create(:stock_unit, status: 'GHOST')
              trb_result_failure
            }
        # rubocop:enable Lint/AmbiguousBlockAssociation

        subject

        ghost = StockUnit.where(status: 'GHOST')
        expect(ghost).to be_empty
      end

      it 'set status to ERROR' do
        allow(TribunalInstance::Stock::Unit::Operation::Load)
          .to receive(:call)
          .with(stock_unit: stock_unit, logger: logger)
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
      expect(TribunalInstance::Stock::Unit::Operation::Load)
        .not_to receive(:call)
      subject
    end

    it 'logs an error' do
      expect(Rails.logger).to receive(:error).with "Couldn't find StockUnit with 'id'=1234"
      subject
    end
  end
end
