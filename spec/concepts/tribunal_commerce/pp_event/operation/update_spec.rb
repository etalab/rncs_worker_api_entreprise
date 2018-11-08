require 'rails_helper'

describe TribunalCommerce::File::PPEvent::Operation::Import, :trb do
  file = Rails.root.join('spec/fixtures/pp_evt.csv')
  let(:type_import) { :flux } # To remove, only used by shared example

  it_behaves_like 'line import',
    DossierEntreprise::Operation::Update,
    file,
    DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING

  context 'when dossier entreprise updates are all successful' do
    before { allow(DossierEntreprise::Operation::Update).to receive(:call).and_return(trb_result_success) }

    it_behaves_like 'line import',
      PersonnePhysique::Operation::Update,
      file,
      PP_HEADER_MAPPING

    it 'is success when all personne morale updates are success' do
      logger = double('logger')
      allow(PersonnePhysique::Operation::Update).to receive(:call).and_return(trb_result_success)
      pp_event_file_import = described_class.call(file_path: file, logger: logger)

      expect(pp_event_file_import).to be_success
    end
  end
end
