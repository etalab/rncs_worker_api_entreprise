require 'rails_helper'

describe Siren do
  it 'relies on SirenFormatValidator for validation' do
    siren = Siren.new(valid_siren)
    expect_any_instance_of(SirenFormatValidator).to receive(:validate_each)

    siren.valid?
  end

  it 'to_s' do
    expect(Siren.new(valid_siren).to_s).to eq(valid_siren)
  end
end
