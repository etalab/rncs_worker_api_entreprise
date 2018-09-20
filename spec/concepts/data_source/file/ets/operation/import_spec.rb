require 'rails_helper'

describe DataSource::File::Ets::Operation::Import do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'ets.csv') }

  subject { described_class.call(file_path: file_path) }

  it 'saves Etablissement records' do
    expect{ subject }.to change(Etablissement, :count).by(5)
  end
end
