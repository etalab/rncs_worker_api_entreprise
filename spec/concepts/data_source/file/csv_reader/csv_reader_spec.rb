require 'rails_helper'

describe DataSource::File::CSVReader do
  describe '.bulk_processing' do

  end

  describe '.line_processing' do

  end

  describe '#proceed' do
    let(:example_file) { Rails.root.join('spec/fixtures/csv_reader_spec.csv') }
    let(:example_mapping) do
      {
        'Maybe Empty' => :maybe_empty,
        'Never Empty' => :never_empty,
      }
    end

    before do
      file = File.new(example_file, 'w+')
      content = <<-CSV
      Maybe Empty;Never Empty
      ;hello
      wow;hey
      much value;012
      1000.00;3,14
      CSV
      file.write(content.unindent)
      file.close
    end

    after { FileUtils.rm_rf(example_file) }

    let(:read_file) do
      reader = described_class.new(example_file, example_mapping)
      lines = nil
      reader.proceed do |batch|
        lines = batch
      end
      lines
    end

    def fetch_line(nb)
      read_file[nb-1]
    end

    it 'returns an array of hash' do
      expect(read_file).to all(be_an_instance_of(Hash))
    end

    it 'maps headers to the given column names' do
      line = fetch_line(2)

      expect(line).to match({ maybe_empty: 'wow', never_empty: 'hey' })
    end

    it 'ignores nil values from the CSV' do
      line = fetch_line(1)

      expect(line).to match({ never_empty: 'hello' })
    end

    it 'reads numbers as string' do
      line = fetch_line(4)

      expect(line[:maybe_empty]).to eq('1000.00')
      expect(line[:never_empty]).to eq('3,14')
    end

    it 'keeps values\'s leading 0 if any' do
      line = fetch_line(3)

      expect(line[:never_empty]).to eq('012')
    end
  end
end
