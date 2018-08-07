require 'rails_helper'

describe DataSource::File::PM::Operation::Store do
  def record_creator
    Entreprise::Operation::CreateWithPM
  end

  def expect_full_import_success
    expect(record_creator).to receive(:call).exactly(5).times.and_return(stub_success)
  end

  def expect_few_errors_during_import
    # Dunno if there is a better / cleaner way : 3 calls will be successfully stubed,
    # the 2 others will fail
    expect(record_creator).to receive(:call).twice.and_return(stub_failure)
    expect(record_creator).to receive(:call).exactly(3).times.and_return(stub_success)
  end

  def expect_all_import_to_fail
    expect(record_creator).to receive(:call).exactly(5).times.and_return(stub_failure)
  end

  def stub_success
    result = double()
    allow(result).to receive(:failure?).and_return(false)
    allow(result).to receive(:success?).and_return(true)
    result
  end

  def stub_failure
    result = double()
    allow(result).to receive(:failure?).and_return(true)
    allow(result).to receive(:success?).and_return(false)
    result
  end

  let(:data) { deserialize_data_from(:pm_stock_file) }
  let(:import_errors_count) { subject[:import_errors_count] }
  let(:end_event) { subject.event.to_h[:semantic] }
  subject { described_class.call(raw_data: data) }

  it 'delegates records creation' do
    expect_full_import_success
    subject
  end

  context 'when all records are successfully created' do
    before { expect_full_import_success }

    it 'is successfull' do
      expect(subject).to be_success
    end

    it 'has counted no error' do
      expect(import_errors_count).to eq(0)
    end

    it 'logs'
  end

  context 'when a few errors occur during import' do
    before { expect_few_errors_during_import }

    it 'counts errors' do
      expect(import_errors_count).to eq(2)
    end

    it 'is successful' do
      expect(subject).to be_success
    end

    it 'logs'
  end

  context 'when import fails entirely' do
    before { expect_all_import_to_fail }

    it 'is failure' do
      expect(subject).to be_failure
    end

    it 'count errors' do
      expect(import_errors_count).to eq(5)
    end

    it 'logs'
  end
end
