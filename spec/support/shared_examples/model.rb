shared_examples 'having event date and label' do
  it { is_expected.to have_db_column(:date_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:libelle_derniere_modification).of_type(:string) }
end

shared_examples 'having rails timestamps' do
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
end

shared_examples 'having dossier greffe id' do
  it { is_expected.to have_db_column(:code_greffe).of_type(:string) }
  it { is_expected.to have_db_column(:numero_gestion).of_type(:string) }
  it { is_expected.to have_db_column(:siren).of_type(:string) }
end

shared_examples '.import' do
  let(:batch_data) do
    [
      { code_greffe: '1', numero_gestion: 'A1', siren: 'siren1' },
      { code_greffe: '2', numero_gestion: 'B2', siren: 'siren2' },
      { code_greffe: '3', numero_gestion: 'C3', siren: 'siren3' },
    ]
  end

  subject { described_class.import(batch_data) }

  it 'delegates to .insert_all! method' do
    expect(described_class).to receive(:insert_all!)

    subject
  end

  it 'adds timestamps values into the incomming data hash' do
    current_time = Time.now
    Timecop.freeze(current_time)
    expect(described_class).to receive(:insert_all!)
      .with(a_collection_containing_exactly(
      { code_greffe: '1', numero_gestion: 'A1', siren: 'siren1', created_at: current_time, updated_at: current_time },
      { code_greffe: '2', numero_gestion: 'B2', siren: 'siren2', created_at: current_time, updated_at: current_time },
      { code_greffe: '3', numero_gestion: 'C3', siren: 'siren3', created_at: current_time, updated_at: current_time },
    ))

    subject
    Timecop.return
  end

  it 'persists the records' do
    expect { subject }.to change(described_class, :count).by(3)
  end
end
