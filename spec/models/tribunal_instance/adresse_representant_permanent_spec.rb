require 'rails_helper'

describe TribunalInstance::AdresseRepresentantPermanent do
  it { is_expected.to belong_to :representant }
end
