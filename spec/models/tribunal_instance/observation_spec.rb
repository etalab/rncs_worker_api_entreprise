require 'rails_helper'

describe TribunalInstance::Observation do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:code).of_type(:string) }
  it { is_expected.to have_db_column(:texte).of_type(:text) }
  it { is_expected.to have_db_column(:date).of_type(:string) }
  it { is_expected.to have_db_column(:numero).of_type(:string) }

  it { is_expected.to belong_to :entreprise }
end
