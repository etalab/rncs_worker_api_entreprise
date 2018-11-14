shared_examples 'bulk import' do |model, file, header_mapping|
  let(:logger) { double('logger') }
  let(:csv_reader) do
    dbl = class_double(DataSource::File::CSVReader)
    dbl.as_null_object
  end

  # :type_import needs to be provided by the parent example group
  let(:result) do
    described_class.call(
      file_path: file,
      type_import: type_import,
      file_reader: csv_reader,
      logger: logger
    )
  end

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
end

shared_examples 'line import' do |line_processor, file, header_mapping|
  # TODO refactor and make mock and null object clearer
  let(:csv_reader) { class_double(DataSource::File::CSVReader).as_null_object }
  let(:logger) { instance_spy(Logger) }

  subject do
    described_class.call(
      file_path: file,
      type_import: type_import,
      file_reader: csv_reader,
      logger: logger,
    )
  end

  before do
    # This mock is mandatory because some tested classes sharing the behaviour
    # of this example group calls CSVReader twice (PM_EVT for example : once to
    # update DossierEntreprise and once to update PersonneMorale records)
    # Yes this is a code smell, can be resolved by doing one model update at
    # the time.
    allow(csv_reader).to receive(:line_processing).and_return(true)

    allow(csv_reader).to receive(:line_processing)
      .with(file, header_mapping)
      .and_yield('first line')
      .and_yield('second line')
  end

  it "calls #{line_processor} for each processed lines" do
    allow(line_processor).to receive(:call).and_return(trb_result_success)
    subject

    expect(line_processor).to have_received(:call).with(data: 'first line').ordered
    expect(line_processor).to have_received(:call).with(data: 'second line').ordered
  end

  context "when #{line_processor} returns a warning message" do
    it 'is success'
    it 'logs the warning message'
  end

  context "when #{line_processor} fails at least once", :trb do
    before do
      failure_context = { error: 'Much error' }
      allow(line_processor)
        .to receive(:call)
        .and_return(trb_result_failure_with(failure_context))
    end

    subject { described_class.call(file_path: file, type_import: type_import, logger: logger) }

    it { is_expected.to be_failure }

    it 'logs the returned error' do
      subject

      expect(logger).to have_received(:error).with('Much error')
    end
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
