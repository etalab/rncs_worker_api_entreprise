require 'rails_helper'

describe PersonnePhysique do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:activite_forain).of_type(:string) }
  it { is_expected.to have_db_column(:dap).of_type(:string) }
  it { is_expected.to have_db_column(:dap_denomination).of_type(:string) }
  it { is_expected.to have_db_column(:dap_objet).of_type(:string) }
  it { is_expected.to have_db_column(:dap_date_cloture).of_type(:string) }
  it { is_expected.to have_db_column(:eirl).of_type(:string) }
  it { is_expected.to have_db_column(:auto_entrepreneur).of_type(:string) }
  it { is_expected.to have_db_column(:conjoint_collab_date_fin).of_type(:string) }

  # PersonnePhysique's identite
  it { is_expected.to have_db_column(:nom_patronyme).of_type(:string) }
  it { is_expected.to have_db_column(:nom_usage).of_type(:string) }
  it { is_expected.to have_db_column(:pseudonyme).of_type(:string) }
  it { is_expected.to have_db_column(:prenoms).of_type(:string) }
  it { is_expected.to have_db_column(:date_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:ville_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:pays_naissance).of_type(:string) }
  it { is_expected.to have_db_column(:nationalite).of_type(:string) }

  # PersonnePhysique's conjoint collaborateur partial identite
  it { is_expected.to have_db_column(:conjoint_collab_nom_patronyme).of_type(:string) }
  it { is_expected.to have_db_column(:conjoint_collab_nom_usage).of_type(:string) }
  it { is_expected.to have_db_column(:conjoint_collab_pseudonyme).of_type(:string) }
  it { is_expected.to have_db_column(:conjoint_collab_prenoms).of_type(:string) }

  # PersonnePhysique's adresse
  it { is_expected.to have_db_column(:adresse_ligne_1).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_ligne_2).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_ligne_3).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_code_postal).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_ville).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_code_commune).of_type(:string) }
  it { is_expected.to have_db_column(:adresse_pays).of_type(:string) }

  # PersonnePhysique's DAP adresse
  it { is_expected.to have_db_column(:dap_adresse_ligne_1).of_type(:string) }
  it { is_expected.to have_db_column(:dap_adresse_ligne_2).of_type(:string) }
  it { is_expected.to have_db_column(:dap_adresse_ligne_3).of_type(:string) }
  it { is_expected.to have_db_column(:dap_adresse_code_postal).of_type(:string) }
  it { is_expected.to have_db_column(:dap_adresse_ville).of_type(:string) }
  it { is_expected.to have_db_column(:dap_adresse_code_commune).of_type(:string) }
  it { is_expected.to have_db_column(:dap_adresse_pays).of_type(:string) }

  # Associations
  it { is_expected.to belong_to(:dossier_entreprise) }

  it_behaves_like 'having event date and label'
  it_behaves_like 'having rails timestamps'
  it_behaves_like 'having dossier greffe id'
  it_behaves_like '.import'
end
