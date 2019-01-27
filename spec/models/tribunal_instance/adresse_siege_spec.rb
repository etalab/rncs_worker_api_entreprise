require 'rails_helper'

describe TribunalInstance::AdresseSiege do
  it { is_expected.to belong_to :entreprise }
end
