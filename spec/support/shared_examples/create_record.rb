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

    expect(error_msg).to eq('The dossier (code_greffe: 9001, numero_gestion: 2016A10937) is not found. The line is ignored and not imported...')
  end
end

# The case is different for a PM or a PP : if a PM or PP is present but not
# its related dossier, an error happened because those records are supposed
# to be the same line in the CSV file.
shared_examples 'related dossier not found (for PM and PP)' do
  let(:record_data) do
    {
      code_greffe: '9001',
      numero_gestion: '2016A10937',
    }
  end

  subject { described_class.call(data: record_data) }

  it { is_expected.to be_failure }

  it 'returns an warning message' do
    error_msg = subject[:error]

    expect(error_msg).to eq('The dossier (code_greffe: 9001, numero_gestion: 2016A10937) is not found. Aborting...')
  end
end
