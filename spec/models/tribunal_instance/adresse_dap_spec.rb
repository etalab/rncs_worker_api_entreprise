require 'rails_helper'

describe TribunalInstance::AdresseDAP do
  it { is_expected.to belong_to :entreprise }
end
