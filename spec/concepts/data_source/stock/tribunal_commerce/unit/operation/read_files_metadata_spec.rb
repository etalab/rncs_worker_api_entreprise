require 'rails_helper'

describe DataSource::Stock::TribunalCommerce::Unit::Operation::ReadFilesMetadata do
  let(:operation_container) do
    Class.new(Trailblazer::Operation) do
      step DataSource::Stock::TribunalCommerce::Unit::Operation::ReadFilesMetadata
    end
  end

  let(:result) { operation_container.call(raw_stock_files: stock_files) }

  describe 'extracted metadata' do
    let(:stock_files) { ['/some/root/path/0101_S1_20170504_1_PM.csv'] }
    subject { result[:stock_files] }

    it 'returns a new array of hash' do
      expect(subject).to be_an_instance_of(Array)
      expect(subject).to all(be_an_instance_of(Hash))
    end

    describe 'parsed metadata' do
      # Stock files are named this way : <code_greffe>_<stock_number>_<AA><MM><JJ>_<run_order>_<label>.csv
      subject {result[:stock_files].first}

      it 'has code_greffe' do
        expect(subject[:code_greffe]).to eq('101')
      end

      it 'has stock_number' do
        expect(subject[:stock_number]).to eq('S1')
      end

      it 'has run_order' do
        expect(subject[:run_order]).to eq('1')
      end

      it 'has label' do
        expect(subject[:label]).to eq('PM')
      end

      it 'has path' do
        expect(subject[:path]).to eq(stock_files.first)
      end
    end
  end

  # TODO fail when a filename don't match the patern
end
