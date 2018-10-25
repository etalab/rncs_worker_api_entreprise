shared_examples 'bulk import' do |model, file, header_mapping|
  let(:csv_reader) do
    dbl = class_double(DataSource::File::CSVReader)
    dbl.as_null_object
  end

  # :type_import needs to be provided by the parent example group
  let(:result) { described_class.call(file_path: file, type_import: type_import, file_reader: csv_reader) }

  it 'calls CSVReader for bulk_processing' do
    result

    expect(csv_reader).to have_received(:bulk_processing)
      .with(file, header_mapping)
      .once
  end

  it "calls #{model}.import for each yielded batch" do
    allow(csv_reader).to receive(:bulk_processing).and_return(true)
    allow(csv_reader).to receive(:bulk_processing)
      .with(file, header_mapping)
      .and_yield('first batch')
      .and_yield('second batch')

    expect(model).to receive(:import).with('first batch').ordered
    expect(model).to receive(:import).with('second batch').ordered

    result
  end

  it "saves #{model} records" do
    # integration test here, no stub
    expect { described_class.call(file_path: file, type_import: type_import) }
      .to change(model, :count).by(5)
  end
end

shared_examples 'line import' do |line_processor, file, header_mapping|
  let(:csv_reader) { class_double(DataSource::File::CSVReader).as_null_object }

  subject { described_class.call(file_path: file, type_import: type_import, file_reader: csv_reader) }

  it 'calls the CSV reader for line processing' do
    subject

    expect(csv_reader).to have_received(:line_processing).with(file, header_mapping)
  end

  it "calls #{line_processor} for each processed lines" do
    allow(csv_reader).to receive(:line_processing)
      .with(file, header_mapping)
      .and_yield('first line')
      .and_yield('second line')

    allow(line_processor).to receive(:call).and_return(trb_result_success)
    subject

    expect(line_processor).to have_received(:call).with(data: 'first line').ordered
    expect(line_processor).to have_received(:call).with(data: 'second line').ordered
  end

  it 'saves the records' do
    pending 'integration test : will pass when PM::Operation::AddPersonnePhysique is implemented'
    expect { subject }.to change(PersonnePhysique, :count).by(5)
  end

  it { is_expected.to be_success }

  context "when #{line_processor} returns a warning message" do
    it 'is success'
    it 'logs the warning message'
  end

  context "when #{line_processor} fails at least once" do
    before do
      allow(line_processor)
        .to receive(:call)
        .and_return(trb_result_failure)
    end

    subject { described_class.call(file_path: file, type_import: type_import) }

    it { is_expected.to be_failure }

    it 'logs the error'
  end
end

shared_examples 'invalid import type' do
  let(:logger) do
    dbl = spy('logger')
    dbl
  end

  subject { described_class.call(type_import: :not_valid, logger: logger) }

  it { is_expected.to be_failure }

  it 'logs the error message' do
    subject

    expect(logger).to have_received(:error)
      .with('Invalid call for file import : import type :not_valid is unknown.')
  end
end
