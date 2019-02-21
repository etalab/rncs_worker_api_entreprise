require 'rails_helper'

describe Representant do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:denomination).of_type(:string) }
  it { is_expected.to have_db_column(:forme_juridique).of_type(:string) }
  it { is_expected.to have_db_column(:siren_pm).of_type(:string) }
  it { is_expected.to have_db_column(:type_representant).of_type(:string) }
  it { is_expected.to have_db_column(:qualite).of_type(:string) }
  it { is_expected.to have_db_column(:conjoint_collab_date_fin).of_type(:string) }
  it { is_expected.to have_db_column(:id_representant).of_type(:string) }

  # Representant's adresse
  it { is_expected.to have_db_column(:adresse_ligne_1).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_ligne_2).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_ligne_3).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_code_postal).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_ville).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_code_commune).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_pays).of_type(:string) }

  # Representant permanent's adresse
  it { is_expected.to have_db_column(:representant_permanent_adresse_ligne_1).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_adresse_ligne_2).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_adresse_ligne_3).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_adresse_code_postal).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_adresse_ville).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_adresse_code_commune).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_adresse_pays).of_type(:string) }

  # Representant's identite
  it { is_expected.to have_db_column(:nom_patronyme).of_type(:string) }
  it { is_expected.to have_db_column(:nom_usage).of_type(:string) }
  it { is_expected.to have_db_column(:pseudonyme).of_type(:string) }
  it { is_expected.to have_db_column(:prenoms).of_type(:string) }
  it { is_expected.to have_db_column(:date_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:ville_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:pays_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:nationalite).of_type(:string) }

  # Representant permanent's identite
  it { is_expected.to have_db_column(:representant_permanent_nom_patronyme).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_nom_usage).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_pseudonyme).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_prenoms).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_date_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_ville_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_pays_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:representant_permanent_nationalite).of_type(:string) }

  # Conjoint collaborateur's identite
  it { is_expected.to have_db_column(:conjoint_collab_nom_patronyme).of_type(:string) }
  it { is_expected.to have_db_column(:conjoint_collab_nom_usage).of_type(:string) }
  it { is_expected.to have_db_column(:conjoint_collab_pseudonyme).of_type(:string) }
  it { is_expected.to have_db_column(:conjoint_collab_prenoms).of_type(:string) }

  # Associations
  it { is_expected.to belong_to(:dossier_entreprise) }

  it_behaves_like 'having event date and label'
  it_behaves_like 'having rails timestamps'
  it_behaves_like 'having dossier greffe id'

  it { is_expected.to be_a_kind_of(ClearDataHelper) }
end
