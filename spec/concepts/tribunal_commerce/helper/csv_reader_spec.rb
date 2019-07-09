require 'rails_helper'

describe TribunalCommerce::Helper::CSVReader do
  describe do
    let(:example_file) { Rails.root.join('spec/fixtures/csv_reader_spec.csv') }
    let(:example_mapping) do
      {
        'Data A' => :data_a,
        'Data B' => :data_b,
      }
    end

    before do
      file = File.new(example_file, 'w+')
      content = <<-CSV
      Data A;Data B
      A1;B1
      ;B2
      A3;B3
      A4;
      A5;B5
      CSV
      file.write(content.unindent)
      file.close
    end

    after { FileUtils.rm_rf(example_file) }

    describe '.bulk_processing' do
      specify 'batch size is configured in config/rncs_sources.yml' do
        reader = described_class.new(example_file, example_mapping)
        options = reader.instance_variable_get(:@options)

        expect(options[:chunk_size])
          .to eq(Rails.configuration.rncs_sources['import_batch_size'])
      end

      it 'reads the file by batch' do
        expect do |block_checker|
          described_class.bulk_processing(example_file, example_mapping, &block_checker)
        end
          .to yield_successive_args(
          [
            { data_a: 'A1', data_b: 'B1' },
            { data_a: nil, data_b: 'B2' },
            { data_a: 'A3', data_b: 'B3' }
          ],
          [
            { data_a: 'A4', data_b: nil },
            { data_a: 'A5', data_b: 'B5' }
          ])
      end
    end

    describe '.line_processing' do
      it 'reads line by line and filter nil values' do
        expect do |block_checker|
          described_class.line_processing(example_file, example_mapping, &block_checker)
        end
          .to yield_successive_args(
            { data_a: 'A1', data_b: 'B1' },
            { data_b: 'B2' },
            { data_a: 'A3', data_b: 'B3' },
            { data_a: 'A4' },
            { data_a: 'A5', data_b: 'B5' },
          )
      end
    end
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
      " cou"cou  "; " blank
      CSV
      file.write(content.unindent)
      file.close
    end

    after { FileUtils.rm_rf(example_file) }

    def read_file(keep_nil: false, **)
      reader = described_class.new(example_file, example_mapping, keep_nil: keep_nil)
      lines = []
      reader.proceed do |batch|
        lines.push(batch)
      end
      lines.flatten
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

    it 'reads numbers as string' do
      line = fetch_line(4)

      expect(line[:maybe_empty]).to eq('1000.00')
      expect(line[:never_empty]).to eq('3,14')
    end

    it 'keeps values\'s leading 0 if any' do
      line = fetch_line(3)

      expect(line[:never_empty]).to eq('012')
    end

    it 'keeps nil values found in the CSV' do
      line = fetch_line(1)

      expect(line).to match({ never_empty: 'hello' })
    end

    it 'ignores nil values if specified' do
      lines = read_file(keep_nil: true)
      line = lines[0]

      expect(line).to match({ maybe_empty: nil, never_empty: 'hello' })
    end

    it 'removes surrounding blank and quotes' do
      line = fetch_line(5)

      expect(line).to match({ maybe_empty: 'cou"cou', never_empty: 'blank'})
    end
  end
end
