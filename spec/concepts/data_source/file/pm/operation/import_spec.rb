require 'rails_helper'

describe DataSource::File::PM::Operation::Import, :trb do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'pm.csv') }
  subject { described_class.call(file_path: file_path, type_import: type_import) }

  shared_examples 'mass import' do |base_class|
    # TODO mock CSVReader yielded batch and expect DossierEntreprise.import
    # to be called with it. Make it a shared example

    it 'saves DossierEntreprise records' do
      expect{ subject }.to change(base_class, :count).by(5)
    end


    # TODO describe CSVReader instance configured for mass import
    # also describe mass import features
  end

  context 'when type_import: :stock' do
    let(:type_import) { :stock }

    it { is_expected.to be_success }

    it_behaves_like 'mass import', DossierEntreprise
    it_behaves_like 'mass import', PersonneMorale
  end

  context 'when type_import: :flux' do
    let(:type_import) { :flux }
    before do
      allow(DataSource::File::PM::Operation::AddPersonneMorale)
        .to receive(:call).and_return(trb_result_success)
    end

    it { is_expected.to be_success }

    it_behaves_like 'mass import', DossierEntreprise

    describe 'PersonneMorale import' do
      describe 'CSVReader instance' do
        it 'is configured for flux'
      end

      it 'calls PM::Operation::AddPersonneMorale for each line' do
        expect(DataSource::File::PM::Operation::AddPersonneMorale).to receive(:call).exactly(5).times

        subject
      end

      context 'when PM::Operation::ImportLine fails' do
        before do
          expect(DataSource::File::PM::Operation::AddPersonneMorale)
            .to receive(:call).and_return(trb_result_failure)
        end

        it { is_expected.to be_failure }

        it 'returns the error (waiting for trb results double with context)'
      end
    end
  end

  context 'when :type_import is unknown' do
    let(:type_import) { :not_valid }

    it { is_expected.to be_failure }

    it 'returns error message' do
      error = subject[:error]

      expect(error).to eq('Invalid import type :not_valid')
    end
  end
end
