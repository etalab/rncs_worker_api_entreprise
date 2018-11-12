require 'rails_helper'

describe TribunalCommerce::File::EtsNouveauModifie::Operation::Import, :trb do
  file = Rails.root.join('spec/fixtures/ets_nouveau_modifie_evt.csv')
  let(:type_import) { :flux } # To remove, only used by shared example

  it_behaves_like 'line import',
    Etablissement::Operation::NouveauModifie,
    file,
    ETS_HEADER_MAPPING

  it 'is success when all etablissements are updated or created' do
    logger = double('logger')
    allow(Etablissement::Operation::NouveauModifie).to receive(:call).and_return(trb_result_success)
    ets_nouveau_modifie_file_import = described_class.call(file_path: file, logger: logger)

    expect(ets_nouveau_modifie_file_import).to be_success
  end
end
