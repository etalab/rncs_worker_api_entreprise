require 'rails_helper'

describe TribunalCommerce::File::EtsSupprime::Operation::Import, :trb do
  file = Rails.root.join('spec/fixtures/ets_supprime_evt.csv')
  let(:type_import) { :flux } # To remove, only used by shared example

  it_behaves_like 'line import',
    Etablissement::Operation::Delete,
    file,
    ETS_HEADER_MAPPING

  it 'is success when all etablissements are deleted' do
    logger = double('logger')
    allow(Etablissement::Operation::Delete).to receive(:call).and_return(trb_result_success)
    ets_supprime_file_import = described_class.call(file_path: file, logger: logger)

    expect(ets_supprime_file_import).to be_success
  end
end
