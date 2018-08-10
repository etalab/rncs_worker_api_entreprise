require 'rails_helper'

describe DataSource::Stock::TribunalCommerce::Unit::Operation::MapFileLoader do
  let(:mapper_params) do
    [
      { random_key: 'random data', label: 'PM' },
      { random_key: 'random data', label: 'PP' },
      { random_key: 'random data', label: 'rep' },
      { random_key: 'random data', label: 'ets' },
      { random_key: 'random data', label: 'obs' },
      { random_key: 'random data', label: 'actes' },
      { random_key: 'random data', label: 'comptes_annuels' }
    ]
  end

  let(:task_container) do
    Class.new(Trailblazer::Operation) do
      step DataSource::Stock::TribunalCommerce::Unit::Operation::MapFileLoader
    end
  end

  subject { task_container.call(stock_list: mapper_params) }
  let(:result) { subject[:stock_list] }

  context 'when hash in params has a valid :label' do
    it { is_expected.to be_success }

    it 'adds a :loader key to the incoming hash params' do
      expect(result).to all(have_key(:loader))
    end

    describe 'mapped label' do
      RSpec.shared_examples 'map loader' do |label, loader|
        it 'knows the loader for the label' do
          temp = subject.select { |e| e[:label] == label }
          hash = temp.first

          expect(hash[:loader]).to eq(loader)
        end
      end

      subject do
        result = task_container.call(stock_list: mapper_params)
        result[:stock_list]
      end

      it_behaves_like 'map loader', 'PM', DataSource::File::PM::Operation::Load
      it_behaves_like 'map loader', 'PP', nil
      it_behaves_like 'map loader', 'rep', nil
      it_behaves_like 'map loader', 'ets', nil
      it_behaves_like 'map loader', 'obs', nil
      it_behaves_like 'map loader', 'actes', nil
      it_behaves_like 'map loader', 'comptes_annuels', nil
    end
  end

  context 'when no :label in hash params' do
    let(:mapper_params) { [{ no_label: 'coucou' }] }

    it { is_expected.to be_failure }
    it 'logs'
  end

  context 'when unknown :label in hash params' do
    let(:mapper_params) { [{ label: 'coucou' }] }

    it { is_expected.to be_failure }
    it 'logs'
  end
end
