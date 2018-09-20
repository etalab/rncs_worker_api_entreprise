require 'rails_helper'

describe DataSource::File::CSVReader do
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }
  let(:csv_file) { fixtures_path.join('pm.csv') }
  let(:header_mapping) { PM_HEADER_MAPPING }

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
    it { is_expected.to have_key(:denomination) }
    it { is_expected.to have_key(:forme_juridique) }
    it { is_expected.to have_key(:sigle) }
    it { is_expected.to have_key(:associe_unique) }
    it { is_expected.to have_key(:activite_principale) }
    it { is_expected.to have_key(:type_capital) }
    it { is_expected.to have_key(:capital_actuel) }
    it { is_expected.to have_key(:capital) }
    it { is_expected.to have_key(:date_cloture) }
    it { is_expected.to have_key(:devise) }
    it { is_expected.to have_key(:date_cloture_exeptionnelle) }
    it { is_expected.to have_key(:economie_sociale_solidaire) }
    it { is_expected.to have_key(:duree_pm) }
    it { is_expected.to have_key(:date_derniere_modification) }
    it { is_expected.to have_key(:libelle_derniere_modification) }
  end

  describe 'dossier entreprise attributes exclusion' do
    # fields in previous specs only
    its(:size) { is_expected.to eq(18) }
  end
end
