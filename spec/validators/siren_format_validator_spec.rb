require 'rails_helper'

class SirenFormatValidatable
  include ActiveModel::Validations
  attr_accessor :siren
  validates :siren, siren_format: true
end

describe SirenFormatValidator do
  subject { SirenFormatValidatable.new }

  it 'validates siren that has 9 digits' do
    subject.siren = valid_siren

    expect(subject).to be_valid
  end

  it 'rejects siren that has 10 digits' do
    subject.siren = '1234567890'

    expect(subject).not_to(be_valid)
    expect(subject.errors.messages[:siren]).to include('9 digits only')
  end

  it 'rejects siren 9 chars long including a letter' do
    subject.siren = '12345678A'

    expect(subject).not_to(be_valid)
    expect(subject.errors.messages[:siren]).to include('9 digits only')
  end

  it 'rejects siren that have 9 digits but no good checksum' do
    subject.siren = invalid_siren

    expect(subject).not_to(be_valid)
    expect(subject.errors.messages[:siren]).to include(
      'must have luhn_checksum ok'
    )
  end
end
