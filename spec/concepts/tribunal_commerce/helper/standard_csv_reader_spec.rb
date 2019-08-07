require 'rails_helper'

RSpec::Matchers.define_negated_matcher :exclude, :include

describe TribunalCommerce::Helper::StandardCSVReader do
  let(:example_file) { Rails.root.join('spec/fixtures/csv_reader_spec.csv') }

  shared_context 'simple csv example' do
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
  end

  describe '#bulk_processing' do
    include_context 'simple csv example'

    subject { described_class.new(example_file, example_mapping, keep_nil: true) }

    specify 'batch size is configured in config/rncs_sources.yml' do
      chunk_size = subject.send(:chunk_size)

      expect(chunk_size).to eq(Rails.configuration.rncs_sources['import_batch_size'])
    end

    # :chunk_size is set to 3 in test environment
    it 'yields chunks of lines' do
      expect { |block_checker| subject.bulk_processing(&block_checker) }
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

    it 'keeps nil values in the target hash'
  end

  describe '#line_processing' do
    include_context 'simple csv example'

    subject { described_class.new(example_file, example_mapping) }

    it 'yields lines one by one' do
      expect { |block_checker| subject.line_processing(&block_checker) }
        .to yield_successive_args(
          { data_a: 'A1', data_b: 'B1' },
          { data_b: 'B2' },
          { data_a: 'A3', data_b: 'B3' },
          { data_a: 'A4' },
          { data_a: 'A5', data_b: 'B5' },
      )
    end

    it 'discards nil values in the result hash'
  end

  describe 'CSV parsing behaviour' do
    let(:example_mapping) do
      {
        'Very data' => :very_data,
        'Much Value' => :much_value,
      }
    end

    before do
      file = File.new(example_file, 'w+')
      content = <<-CSV
      Very data;Much Value;Vérï acçents;l.o.l;   Space
      ;hello;bondour;coucou;espace
      wow;hey;yo;le nouveau son;ciel
      much value;012;test;'';universe
      CSV
      file.write(content.unindent)
      file.close
    end

    after { FileUtils.rm_rf(example_file) }

    it 'transforms header according to the headers mapping dictionary' do
      # Note that the mapping is done after header's harmonization
      example_mapping[:very_data] = :header_changed

      expect(parsed_csv).to all(include(:header_changed))
      expect(parsed_csv).to all(exclude(:very_data))
    end

    it 'discards values for headers mapped to nil' do
      example_mapping[:much_value] = nil

      expect(parsed_csv).to all(exclude(:much_value, nil))
    end

    it 'strips headers surrounding spaces' do
      expect(parsed_csv).to all(include(:space))
    end

    it 'symbolizes headers' do
      example_mapping.delete('Much Value')

      expect(parsed_csv).to all(include(:very_data, :much_value))
    end

    it 'transliterates headers name' do
      expect(parsed_csv).to all(include(:veri_accents))
    end

    it 'removes dot characters from headers' do
      expect(parsed_csv).to all(include(:lol))
    end

    def parsed_csv
      reader = described_class.new(example_file, example_mapping, keep_nil: true)
      csv = []
      reader.send(:proceed) { |batch| csv << batch }
      csv.flatten
    end
  end
end
