require 'rails_helper'

describe Representant do
  # it is expected to have one identite
  # it is expected to have one adresse
  # it is expected to have one representant_permanent_identite
  # it is expected to have one representant_permanent_adresse
  # it is expected to have one conjoint_collaborateur_identite

  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:denomination).of_type(:string) }
  it { is_expected.to have_db_column(:forme_juridique).of_type(:string) }
  it { is_expected.to have_db_column(:siren).of_type(:string) }
  it { is_expected.to have_db_column(:type).of_type(:string) }
  it { is_expected.to have_db_column(:qualite).of_type(:string) }
  it { is_expected.to have_db_column(:conjoint_collaborateur_date_fin).of_type(:string) }
  it { is_expected.to have_db_column(:id_representant).of_type(:string) }

  it { is_expected.to have_db_column(:date_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:libelle_derniere_modification).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
end
