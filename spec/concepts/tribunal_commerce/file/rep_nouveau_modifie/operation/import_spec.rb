require 'rails_helper'

describe TribunalCommerce::File::RepNouveauModifie::Operation::Import, :trb do
  file = Rails.root.join('spec/fixtures/rep_nouveau_modifie_evt.csv')
  let(:type_import) { :flux } # To remove, only used by shared example

  it_behaves_like 'line import',
    Representant::Operation::NouveauModifie,
    file,
    REP_HEADER_MAPPING

  it 'is success when all representants are updated or created' do
    logger = double('logger')
    allow(Representant::Operation::NouveauModifie).to receive(:call).and_return(trb_result_success)
    rep_nouveau_modifie_file_import = described_class.call(file_path: file, logger: logger)

    expect(rep_nouveau_modifie_file_import).to be_success
  end
end
