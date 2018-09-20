require 'rails_helper'

describe DataSource::File::PM::Operation::Import do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'pm.csv') }

  subject { described_class.call(file_path: file_path) }

  # TODO mock CSVReader yielded batch and expect DossierEntreprise.import
  # to be called with it. Make it a shared example

  it 'saves DossierEntreprise records' do
    expect{ subject }.to change(DossierEntreprise, :count).by(5)
  end

  it 'saves PersonneMorale records' do
    expect{ subject }.to change(PersonneMorale, :count).by(5)
  end

  it 'chunks the file imports'
end
