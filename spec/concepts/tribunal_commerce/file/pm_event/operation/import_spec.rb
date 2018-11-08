require 'rails_helper'

describe TribunalCommerce::File::PMEvent::Operation::Import, :trb do
  file = Rails.root.join('spec/fixtures/pm_evt.csv')

  # TODO Remove this : it is set because it's needed by the shared example
  let(:type_import) { :flux }

  it_behaves_like 'line import',
    DossierEntreprise::Operation::Update,
    file,
    DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING

  context 'when dossier entreprise updates are all successful' do
    before { allow(DossierEntreprise::Operation::Update).to receive(:call).and_return(trb_result_success) }

    it_behaves_like 'line import',
      PersonneMorale::Operation::Update,
      file,
      PM_HEADER_MAPPING

    it 'is success when all personne morale updates are success' do
      logger = double('logger')
      allow(PersonneMorale::Operation::Update).to receive(:call).and_return(trb_result_success)
      pm_event_file_import = described_class.call(file_path: file, logger: logger)

      expect(pm_event_file_import).to be_success
    end
  end
end
