require 'rails_helper'

describe TribunalInstance::AdresseEtablissement do
  it { is_expected.to belong_to :etablissement }
end
