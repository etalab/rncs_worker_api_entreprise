require 'rails_helper'

describe TribunalInstance::AdresseDomiciliataire do
  it { is_expected.to belong_to(:entreprise) }
end
