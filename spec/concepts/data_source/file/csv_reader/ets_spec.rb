require 'rails_helper'

describe DataSource::File::CSVReader do
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }
  let(:csv_file) { fixtures_path.join('ets.csv') }
  let(:header_mapping) { ETS_HEADER_MAPPING }

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
    it { is_expected.to have_key(:type_etablissement) }
    it { is_expected.to have_key(:siege_pm) }
    it { is_expected.to have_key(:rcs_registre) }
    it { is_expected.to have_key(:adresse_ligne_1) }
    it { is_expected.to have_key(:adresse_ligne_2) }
    it { is_expected.to have_key(:adresse_ligne_3) }
    it { is_expected.to have_key(:adresse_code_postal) }
    it { is_expected.to have_key(:adresse_ville) }
    it { is_expected.to have_key(:adresse_code_commune) }
    it { is_expected.to have_key(:adresse_pays) }
    it { is_expected.to have_key(:domiciliataire_nom) }
    it { is_expected.to have_key(:domiciliataire_siren) }
    it { is_expected.to have_key(:domiciliataire_greffe) }
    it { is_expected.to have_key(:domiciliataire_complement) }
    it { is_expected.to have_key(:siege_domicile_representant) }
    it { is_expected.to have_key(:nom_commercial) }
    it { is_expected.to have_key(:enseigne) }
    it { is_expected.to have_key(:activite_ambulante) }
    it { is_expected.to have_key(:activite_saisonniere) }
    it { is_expected.to have_key(:activite_non_sedentaire) }
    it { is_expected.to have_key(:date_debut_activite) }
    it { is_expected.to have_key(:activite) }
    it { is_expected.to have_key(:origine_fonds) }
    it { is_expected.to have_key(:origine_fonds_info) }
    it { is_expected.to have_key(:type_exploitation) }
    it { is_expected.to have_key(:id_etablissement) }
    it { is_expected.to have_key(:date_derniere_modification) }
    it { is_expected.to have_key(:libelle_derniere_modification) }
  end

  describe 'dossier entreprise attributes exclusion' do
    # fields in previous specs only
    its(:size) { is_expected.to eq(31) }
  end
end
