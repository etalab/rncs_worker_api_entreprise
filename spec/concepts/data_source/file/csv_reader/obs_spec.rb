require 'rails_helper'

describe DataSource::File::CSVReader do
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }
  let(:csv_file) { fixtures_path.join('obs.csv') }
  let(:header_mapping) { OBS_HEADER_MAPPING }

  subject do
    raw_data = []
    reader = described_class.new(csv_file, header_mapping)

    reader.proceed do |batch|
      raw_data = batch
    end
    raw_data.first
  end

  describe 'header keys transformations' do
    it { is_expected.to have_key(:code_greffe) }
    it { is_expected.to have_key(:numero_gestion) }
    it { is_expected.to have_key(:siren) }
    it { is_expected.to have_key(:id_observation) }
    it { is_expected.to have_key(:numero) }
    it { is_expected.to have_key(:date_ajout) }
    it { is_expected.to have_key(:date_suppression) }
    it { is_expected.to have_key(:texte) }
    it { is_expected.to have_key(:date_derniere_modification) }
    # TODO fix this spec since I can't let an empty space at the end of the line because of vim
    # it { is_expected.to have_key(:etat) }
  end

  describe 'dossier entreprise attributes exclusion' do
    # fields in previous specs only
    its(:size) { is_expected.to eq(10) }
  end
end
