require 'rails_helper'

describe TribunalInstance::AdresseRepresentant do
  it { is_expected.to belong_to(:representant) }
end
