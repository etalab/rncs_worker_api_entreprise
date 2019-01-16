require 'rails_helper'

describe PersonneMorale do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:denomination).of_type(:string) }
  it { is_expected.to have_db_column(:sigle).of_type(:string) }
  it { is_expected.to have_db_column(:forme_juridique).of_type(:string) }
  it { is_expected.to have_db_column(:associe_unique).of_type(:string) }
  it { is_expected.to have_db_column(:activite_principale).of_type(:string) }
  it { is_expected.to have_db_column(:type_capital).of_type(:string) }
  it { is_expected.to have_db_column(:capital).of_type(:string) }
  it { is_expected.to have_db_column(:capital_actuel).of_type(:string) }
  it { is_expected.to have_db_column(:devise).of_type(:string) }
  it { is_expected.to have_db_column(:date_cloture).of_type(:string) }
  it { is_expected.to have_db_column(:date_cloture_exceptionnelle).of_type(:string) }
  it { is_expected.to have_db_column(:economie_sociale_solidaire).of_type(:string) }
  it { is_expected.to have_db_column(:duree_pm).of_type(:string) }

  # Associations
  it { is_expected.to belong_to(:dossier_entreprise) }

  it_behaves_like 'having event date and label'
  it_behaves_like 'having rails timestamps'
  it_behaves_like 'having dossier greffe id'
end
