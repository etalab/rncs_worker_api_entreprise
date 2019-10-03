require 'rails_helper'

describe ZIP::Operation::Extract do
  # TODO: deal with not valid files (thinking about :group operation option)
  # TODO deal with unzip errors

  # Archive manually created for tests.
  # Contains files :
  #  - example.csv
  #  - file_1.txt
  #  - wow.example
  #  - very_nested/test.xml
  let(:zip_path) { Rails.root.join('spec', 'concepts', 'zip', 'example.zip').to_s }
  let(:dest_directory) { Rails.root.join('tmp', 'example').to_s }

  subject { described_class.call(path: zip_path) }

  after { FileUtils.rm_rf(dest_directory) } # clean extracted files

  it 'is successful' do
    expect(subject).to be_success
  end

  it 'extracts into a directory named from the zip' do
    subject
    expect(File.directory?(dest_directory)).to eq(true)
  end

  it 'returns the unzip destination directory' do
    expect(subject[:dest_directory]).to eq(dest_directory)
  end

  it 'returns the list of extracted files absolute path' do
    file_list = subject[:extracted_files]

    expect(file_list.size).to eq(4)
    expect(file_list).to include(File.join(dest_directory, 'example.csv'))
    expect(file_list).to include(File.join(dest_directory, 'file_1.txt'))
    expect(file_list).to include(File.join(dest_directory, 'wow.example'))
    expect(file_list).to include(File.join(dest_directory, 'very_nested', 'test.xml'))
  end

  it 'ignores nested subdirectories' do
    file_list = subject[:extracted_files]

    expect(file_list).to_not include(File.join(dest_directory, 'very_nested'))
  end

  context 'when file is not found' do
    let(:zip_path) { Rails.root.join('tmp', 'you_will_never_find_me').to_s }

    it { is_expected.to be_failure }

    its([:error]) { is_expected.to match /unzip:  cannot find or open .+you_will_never_find_me.+/ }
  end
end
