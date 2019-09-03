require 'rails_helper'

describe Etablissement do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:type_etablissement).of_type(:string) }
  it { is_expected.to have_db_column(:siege_pm).of_type(:string) }
  it { is_expected.to have_db_column(:rcs_registre).of_type(:string) }
  it { is_expected.to have_db_column(:domiciliataire_nom).of_type(:string) }
  it { is_expected.to have_db_column(:domiciliataire_siren).of_type(:string) }
  it { is_expected.to have_db_column(:domiciliataire_greffe).of_type(:string) }
  it { is_expected.to have_db_column(:domiciliataire_complement).of_type(:string) }
  it { is_expected.to have_db_column(:siege_domicile_representant).of_type(:string) }
  it { is_expected.to have_db_column(:nom_commercial).of_type(:string) }
  it { is_expected.to have_db_column(:enseigne).of_type(:string) }
  it { is_expected.to have_db_column(:activite_ambulante).of_type(:string) }
  it { is_expected.to have_db_column(:activite_saisonniere).of_type(:string) }
  it { is_expected.to have_db_column(:activite_non_sedentaire).of_type(:string) }
  it { is_expected.to have_db_column(:date_debut_activite).of_type(:string) }
  it { is_expected.to have_db_column(:activite).of_type(:string) }
  it { is_expected.to have_db_column(:origine_fonds).of_type(:string) }
  it { is_expected.to have_db_column(:origine_fonds_info).of_type(:string) }
  it { is_expected.to have_db_column(:type_exploitation).of_type(:string) }
  it { is_expected.to have_db_column(:id_etablissement).of_type(:string) } # siret ?

  # Etablissement's adresse
  it { is_expected.to have_db_column(:adresse_ligne_1).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_ligne_2).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_ligne_3).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_code_postal).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_ville).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_code_commune).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_pays).of_type(:string) }

  # Associations
  it { is_expected.to belong_to(:dossier_entreprise) }

  it_behaves_like 'having event date and label'
  it_behaves_like 'having rails timestamps'
  it_behaves_like 'having dossier greffe id'
  it_behaves_like '.import'
end
