require 'rails_helper'

describe DataSource::File::CSVReader do
  subject do
    reader = described_class.new(example_file, example_mapping, options)
    processed_lines = []
    reader.proceed do |lines|
      processed_lines = lines
    end
    processed_lines.first
  end

  describe 'filter_nil_values option' do
    let(:example_file) { Rails.root.join('spec/fixtures/empty_value.csv').to_s }
    let(:example_mapping) { { 'Empty value' => :empty_value, 'Not empty' => :not_empty } }
    let(:options) { {} }

    it 'defaults to false' do
      expect(subject).to include(empty_value: nil)
      expect(subject).to include(not_empty: 'coucou')
    end

    it 'ignores nil values' do
      options[:filter_nil_values] = true
      expect(subject).to_not include(:empty_value)
      expect(subject).to include(not_empty: 'coucou')
    end
  end
end
