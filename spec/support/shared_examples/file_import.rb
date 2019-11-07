shared_examples 'bulk_import' do |import_method, imported_model, file_mapping|
  let(:file_path) { 'very path' }
  let(:logger) { instance_spy(Logger) }
  let(:csv_reader) { instance_spy(TribunalCommerce::Helper::StandardCSVReader) }

  # Mocking the CSVReader here for unit tests
  # This callback also ensure the import method call will initialize the
  # CSVReader correctly (with the right :keep_nil option)
  before do
    allow(TribunalCommerce::Helper::StandardCSVReader)
      .to receive(:new)
      .with(file_path, file_mapping, keep_nil: true)
      .and_return(csv_reader)
  end

  subject do
    importer = described_class.new(logger)
    importer.send(import_method, file_path)
  end

  it 'logs the start of the file import' do
    subject

    expect(logger).to have_received(:info)
      .with("Starting bulk import of #{imported_model} from `#{file_path}`:")
  end

  context 'when the file reader works' do
    before do
      # Mock real import method in order to test the flow here, not integrations specs
      allow(imported_model).to receive(:import)
      # Same for the CSV reader, we mock its real beheviour for flow testing
      allow(csv_reader).to receive(:bulk_processing)
        .and_yield(['first batch'])
        .and_yield(['second batch'])
    end

    context "when the #{imported_model}.import method is successful" do
      it 'returns a truthy value' do # this is important for the underlying Trailblazer flow
        expect(subject).to be_truthy
      end

      it "calls #{imported_model}.import for each yielded batch" do
        subject

        expect(imported_model).to have_received(:import).with(['first batch']).ordered
        expect(imported_model).to have_received(:import).with(['second batch']).ordered
      end

      it 'logs the file has been imported successfully' do
        subject

        expect(logger).to have_received(:info)
          .with("Import of file #{file_path} is complete!")
      end
    end
  end
end

shared_examples 'import_line_by_line' do |import_method, line_processor, file_mapping|
  let(:file_path) { 'im a path lol' }
  let(:logger) { instance_spy(Logger) }
  let(:csv_reader) { instance_spy(TribunalCommerce::Helper::StandardCSVReader) }

  # Mocking the CSVReader here for unit tests
  # This callback also ensure the import method call will initialize the
  # CSVReader correctly (with the right :keep_nil option)
  before do
    allow(TribunalCommerce::Helper::StandardCSVReader)
      .to receive(:new)
      .with(file_path, file_mapping, keep_nil: false)
      .and_return(csv_reader)
  end

  subject do
    importer = described_class.new(logger)
    importer.send(import_method, file_path)
  end

  it 'logs the start of the file import' do
    subject

    expect(logger).to have_received(:info)
      .with("Starting import of #{file_path} with #{line_processor} :")
  end

  context 'when the file reader works' do
    before do
      allow(csv_reader).to receive(:line_processing)
        .and_yield('first line')
        .and_yield('second line')
    end

    it 'returns a truthy value' do
      allow(line_processor).to receive(:call).and_return(trb_result_success)

      expect(subject).to be_truthy
    end

    it "calls #{line_processor} for each line read" do
      allow(line_processor).to receive(:call).and_return(trb_result_success)
      subject

      expect(line_processor).to have_received(:call).with(data: 'first line').ordered
      expect(line_processor).to have_received(:call).with(data: 'second line').ordered
    end

    it "logs warning messages returned by #{line_processor} if any" do
      warning = { warning: 'This is a warning message !' }
      allow(line_processor).to receive(:call).and_return(trb_result_success_with(warning))
      subject

      expect(logger).to have_received(:warn).with('This is a warning message !').twice
    end

    it 'logs the file has been imported sucessfully' do
      allow(line_processor).to receive(:call).and_return(trb_result_success)
      subject

      expect(logger).to have_received(:info)
        .with("Import of file #{file_path} is complete !")
    end

    context "when #{line_processor} fails at least once", :trb do
      before do
        failure_context = { error: 'Much error' }
        allow(line_processor)
          .to receive(:call)
          .and_return(trb_result_failure_with(failure_context))
      end

      it { is_expected.to eq(false) }

      it 'logs the returned error' do
        subject

        expect(logger).to have_received(:error).with('Much error')
      end

      it 'logs the file failed to import' do
        subject

        expect(logger).to have_received(:error)
          .with("Fail to import file `#{file_path}`.")
      end
    end
  end
end
