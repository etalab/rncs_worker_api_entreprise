require 'rails_helper'

describe DataSource::File::PM::Operation::Import, :trb do
  file = Rails.root.join('spec/fixtures/pm.csv')

  subject { described_class.call(file_path: file, type_import: type_import) }

  context 'when type_import: :stock' do
    let(:type_import) { :stock }

    it_behaves_like 'bulk import', DossierEntreprise, file, DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING

    it_behaves_like 'bulk import', PersonneMorale, file, PM_HEADER_MAPPING

    it { is_expected.to be_success }
  end

  context 'when type_import: :flux' do
    let(:type_import) { :flux }

    it_behaves_like 'bulk import', DossierEntreprise, file, DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING

    it_behaves_like 'line import',
      DataSource::File::PM::Operation::AddPersonneMorale,
      PersonneMorale,
      file,
      PM_HEADER_MAPPING

    it 'is success' do
      allow(DataSource::File::PM::Operation::AddPersonneMorale)
        .to receive(:call)
        .and_return(trb_result_success)

      expect(subject).to be_success
    end
  end

  context 'when :type_import is unknown' do
    it_behaves_like 'invalid import type'
  end
end
