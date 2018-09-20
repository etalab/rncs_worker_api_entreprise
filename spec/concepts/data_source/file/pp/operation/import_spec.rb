require 'rails_helper'

describe DataSource::File::PP::Operation::Import do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'pp.csv') }

  subject { described_class.call(file_path: file_path) }

  it 'saves DossierEntreprise records' do
    expect{ subject }.to change(DossierEntreprise, :count).by(5)
  end

  it 'saves PersonnePhysique records' do
    expect{ subject }.to change(PersonnePhysique, :count).by(5)
  end
end
