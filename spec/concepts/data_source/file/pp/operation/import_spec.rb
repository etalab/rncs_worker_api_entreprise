require 'rails_helper'

describe DataSource::File::PP::Operation::Import, :trb do
  let(:logger) { double('logger') }
  file = Rails.root.join('spec', 'fixtures', 'pp.csv')

  subject { described_class.call(file_path: file, type_import: type_import, logger: logger) }

  context 'when type_import: :stock' do
    let(:type_import) { :stock }

    it_behaves_like 'bulk import', DossierEntreprise, file, DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING

    it_behaves_like 'bulk import', PersonnePhysique, file, PP_HEADER_MAPPING

    it { is_expected.to be_success }
  end

  context 'when type_import: :flux' do
    let(:type_import) { :flux }

    it_behaves_like 'bulk import', DossierEntreprise, file, DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING

    it_behaves_like 'line import',
      PersonnePhysique::Operation::Create,
      file,
      PP_HEADER_MAPPING

    it 'is success if each line import is successfull' do
      allow(PersonnePhysique::Operation::Create)
        .to receive(:call).and_return(trb_result_success)

      expect(subject).to be_success
    end
  end

  context 'when :type_import is unknown' do
    it_behaves_like 'invalid import type'
  end
end
