require 'rails_helper'

describe DataSource::File::Rep::Operation::Import do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'rep.csv') }

  subject { described_class.call(file_path: file_path) }

  it 'saves Representant records' do
    expect{ subject }.to change(Representant, :count).by(5)
  end
end
