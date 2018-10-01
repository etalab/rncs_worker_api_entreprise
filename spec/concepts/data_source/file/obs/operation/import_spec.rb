require 'rails_helper'

describe DataSource::File::Obs::Operation::Import do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'obs.csv') }

  subject { described_class.call(file_path: file_path) }

  it 'saves Observation records' do
    pending 'fix this spec since I can\'t let an empty space at the end of the line because of vim'
    expect{ subject }.to change(Observation, :count).by(5)
  end
end
