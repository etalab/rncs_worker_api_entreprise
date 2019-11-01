shared_examples 'related dossier not found' do
  let(:record_data) do
    {
      code_greffe: '9001',
      numero_gestion: '2016A10937',
    }
  end

  subject { described_class.call(data: record_data) }

  it { is_expected.to be_success }

  it 'returns an warning message' do
    error_msg = subject[:warning]

    expect(error_msg).to eq('The dossier (code_greffe: 9001, numero_gestion: 2016A10937) is not found. Aborting...')
  end
end
