require 'rails_helper'

describe TribunalCommerce::File::RepPartant::Operation::Import, :trb do
  file = Rails.root.join('spec/fixtures/rep_partant_evt.csv')
  let(:type_import) { :flux } # To remove, only used by shared example

  it_behaves_like 'line import',
    Representant::Operation::Delete,
    file,
    REP_HEADER_MAPPING

  it 'is success when all representants are removed from the dossier' do
    logger = double('logger')
    allow(Representant::Operation::Delete).to receive(:call).and_return(trb_result_success)
    rep_partant_file_import = described_class.call(file_path: file, logger: logger)

    expect(rep_partant_file_import).to be_success
  end
end
