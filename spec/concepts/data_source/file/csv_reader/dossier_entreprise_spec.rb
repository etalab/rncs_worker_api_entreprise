require 'rails_helper'

describe DataSource::File::CSVReader do
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }

  subject do
    raw_data = []
    reader = described_class.new(csv_file, header_mapping)

    reader.proceed do |batch|
      raw_data = batch
    end
    raw_data.first
  end

  shared_examples 'header keys transformations' do
    it { is_expected.to have_key(:code_greffe) }
    it { is_expected.to have_key(:nom_greffe) }
    it { is_expected.to have_key(:numero_gestion) }
    it { is_expected.to have_key(:siren) }
    it { is_expected.to have_key(:type_inscription) }
    it { is_expected.to have_key(:date_immatriculation) }
    it { is_expected.to have_key(:date_premiere_immatriculation) }
    it { is_expected.to have_key(:date_radiation) }
    it { is_expected.to have_key(:date_transfert) }
    it { is_expected.to have_key(:sans_activite) }
    it { is_expected.to have_key(:date_debut_activite) }
    it { is_expected.to have_key(:date_debut_premiere_activite) }
    it { is_expected.to have_key(:date_cessation_activite) }
    it { is_expected.to have_key(:date_derniere_modification) }
    it { is_expected.to have_key(:libelle_derniere_modification) }
  end

  context 'when read from pm file' do
    let(:csv_file) { fixtures_path.join('pm.csv') }
    let(:header_mapping) { DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING }

    it_behaves_like 'header keys transformations'

    # fields in previous specs only
    its(:size) { is_expected.to eq(15) }
  end

  context 'when read from pp file' do
    let(:csv_file) { fixtures_path.join('pp.csv') }
    let(:header_mapping) { DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING }

    it_behaves_like 'header keys transformations'

    # fields in previous specs only
    its(:size) { is_expected.to eq(15) }
  end

  # TODO move generic tests into a csv_reader_spec.rb file
  context 'when values are string numbers it keeps leading zeros' do
    let(:csv_file) { fixtures_path.join('pm.csv') }
    let(:header_mapping) { DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING }

    its([:code_greffe]) { is_expected.to eq('0888') }
    its([:siren]) { is_expected.to eq('051607251') }
  end
end
