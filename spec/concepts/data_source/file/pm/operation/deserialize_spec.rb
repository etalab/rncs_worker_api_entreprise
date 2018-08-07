require 'rails_helper'

describe DataSource::File::PM::Operation::Deserialize do
  let(:csv_data) do
    [{
      code_greffe: 101,
      nom_greffe: "Bourg-en-Bresse",
      numero_gestion: "2015B01079",
      siren: 813543063,
      type_inscription: "P",
      date_immatriculation: "2015-09-17",
      date_1re_immatriculation: "2015-09-17",
      date_radiation: "2020-12-12",
      date_transfert: "2018-06-07",
      sans_activité: "non",
      date_debut_activité: "2015-10-01",
      date_début_1re_activité: "2015-10-01",
      date_cessation_activité: "2019-03-12",
      denomination: "MARGARITELLI FERROVIARIA",
      sigle: "Much Sigle",
      forme_juridique: "Société de droit étranger",
      associé_unique: "non",
      activité_principale: "Industrie pour la production et la pose de produits en béton y compris celle pour les lignes ferroviaires, de métros et tramways.",
      type_capital: "F",
      capital: 6000000.0,
      capital_actuel: 1000000.0,
      devise: "Euros",
      date_clôture: "31 Décembre",
      "date_clôture_except.": "21 octobre",
      economie_sociale_solidaire: "Non",
      durée_pm: 15,
      date_greffe: "2015-09-17",
      libelle_evt: "Création"
    }]
  end
  subject do
    deserialize = described_class.call(raw_data: csv_data)
    deserialize[:raw_data].first
  end

  it 'rename entreprise attributes keys' do
    expect(subject.size).to eq(14)
    expect(subject.fetch(:code_greffe)).to eq(101)
    expect(subject.fetch(:nom_greffe)).to eq('Bourg-en-Bresse')
    expect(subject.fetch(:numero_gestion)).to eq('2015B01079')
    expect(subject.fetch(:siren)).to eq(813543063)
    expect(subject.fetch(:type_inscription)).to eq('P')
    expect(subject.fetch(:date_immatriculation)).to eq('2015-09-17')
    expect(subject.fetch(:date_radiation)).to eq('2020-12-12')
    expect(subject.fetch(:date_transfert)).to eq('2018-06-07')
    expect(subject.fetch(:date_premiere_immatriculation)).to eq('2015-09-17')
    expect(subject.fetch(:sans_activite)).to eq('non')
    expect(subject.fetch(:date_debut_activite)).to eq('2015-10-01')
    expect(subject.fetch(:date_debut_premiere_activite)).to eq('2015-10-01')
    expect(subject.fetch(:date_cessation_activite)).to eq('2019-03-12')

    # TODO Duplicate date_derniere_modification and libelle_derniere_modification
    # for both Entreprise and PersonneMorale
  end

  it 'nests the personne morale data' do
    expect(subject.fetch(:personne_morale)).to be_an_instance_of(Hash)
  end

  it 'renames personne morale attributes keys' do
    pm = subject.fetch(:personne_morale)

    expect(pm.size).to eq(15)
    expect(pm.fetch(:denomination)).to eq('MARGARITELLI FERROVIARIA')
    expect(pm.fetch(:associe_unique)).to eq('non')
    expect(pm.fetch(:capital)).to eq(6000000.0)
    expect(pm.fetch(:capital_actuel)).to eq(1000000.0)
    expect(pm.fetch(:date_cloture)).to eq('31 Décembre')
    expect(pm.fetch(:date_cloture_exeptionnelle)).to eq('21 octobre')
    expect(pm.fetch(:date_derniere_modification)).to eq('2015-09-17')
    expect(pm.fetch(:devise)).to eq('Euros')
    expect(pm.fetch(:duree_pm)).to eq(15)
    expect(pm.fetch(:economie_sociale_solidaire)).to eq('Non')
    expect(pm.fetch(:forme_juridique)).to eq('Société de droit étranger')
    expect(pm.fetch(:libelle_derniere_modification)).to eq('Création')
    expect(pm.fetch(:sigle)).to eq('Much Sigle')
    expect(pm.fetch(:type_capital)).to eq('F')
    expect(pm.fetch(:activite_principale)).to eq('Industrie pour la production et la pose de produits en béton y compris celle pour les lignes ferroviaires, de métros et tramways.')
  end
end
