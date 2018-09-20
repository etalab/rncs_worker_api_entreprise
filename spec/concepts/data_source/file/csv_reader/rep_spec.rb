require 'rails_helper'

describe DataSource::File::CSVReader do
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }
  let(:csv_file) { fixtures_path.join('rep.csv') }
  let(:header_mapping) { REP_HEADER_MAPPING }

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
    it { is_expected.to have_key(:type_representant) }
    it { is_expected.to have_key(:nom_patronyme) }
    it { is_expected.to have_key(:nom_usage) }
    it { is_expected.to have_key(:pseudonyme) }
    it { is_expected.to have_key(:prenoms) }
    it { is_expected.to have_key(:date_naissance) }
    it { is_expected.to have_key(:ville_naissance) }
    it { is_expected.to have_key(:pays_naissance) }
    it { is_expected.to have_key(:nationalite) }
    it { is_expected.to have_key(:denomination) }
    it { is_expected.to have_key(:siren_pm) }
    it { is_expected.to have_key(:forme_juridique) }
    it { is_expected.to have_key(:adresse_ligne_1) }
    it { is_expected.to have_key(:adresse_ligne_2) }
    it { is_expected.to have_key(:adresse_ligne_3) }
    it { is_expected.to have_key(:adresse_code_postal) }
    it { is_expected.to have_key(:adresse_ville) }
    it { is_expected.to have_key(:adresse_code_commune) }
    it { is_expected.to have_key(:adresse_pays) }
    it { is_expected.to have_key(:qualite) }
    it { is_expected.to have_key(:representant_permanent_nom_patronyme) }
    it { is_expected.to have_key(:representant_permanent_nom_usage) }
    it { is_expected.to have_key(:representant_permanent_pseudonyme) }
    it { is_expected.to have_key(:representant_permanent_prenoms) }
    it { is_expected.to have_key(:representant_permanent_date_naissance) }
    it { is_expected.to have_key(:representant_permanent_ville_naissance) }
    it { is_expected.to have_key(:representant_permanent_pays_naissance) }
    it { is_expected.to have_key(:representant_permanent_nationalite) }
    it { is_expected.to have_key(:representant_permanent_adresse_ligne_1) }
    it { is_expected.to have_key(:representant_permanent_adresse_ligne_2) }
    it { is_expected.to have_key(:representant_permanent_adresse_ligne_3) }
    it { is_expected.to have_key(:representant_permanent_adresse_code_postal) }
    it { is_expected.to have_key(:representant_permanent_adresse_ville) }
    it { is_expected.to have_key(:representant_permanent_adresse_code_commune) }
    it { is_expected.to have_key(:representant_permanent_adresse_pays) }
    it { is_expected.to have_key(:conjoint_collab_nom_patronyme) }
    it { is_expected.to have_key(:conjoint_collab_nom_usage) }
    it { is_expected.to have_key(:conjoint_collab_prenoms) }
    it { is_expected.to have_key(:conjoint_collab_pseudonyme) }
    it { is_expected.to have_key(:conjoint_collab_date_fin) }
    it { is_expected.to have_key(:id_representant) }
    it { is_expected.to have_key(:date_derniere_modification) }
    it { is_expected.to have_key(:libelle_derniere_modification) }
  end

  describe 'dossier entreprise attributes exclusion' do
    # fields in previous specs only
    its(:size) { is_expected.to eq(46) }
  end
end
