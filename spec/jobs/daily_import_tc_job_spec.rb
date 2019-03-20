require 'rails_helper'

describe DailyImportTCJob do
  it 'delegates to TribunalCommerce::Operation::DailyImport' do
    expect(TribunalCommerce::Operation::DailyImport).to receive(:call)

    described_class.perform_now
  end
end
