require 'rails_helper'

describe Etablissement::Operation::Delete do
  let(:data) do
    {
      code_greffe: '1234',
      numero_gestion: '1A2B3C',
      id_etablissement: '1'
    }
  end

  subject { described_class.call(data: data) }

  context 'when the etablissement exists in database' do
    before do
      create(
        :etablissement,
        code_greffe: '1234',
        numero_gestion: '1A2B3C',
        id_etablissement: '1'
      )
    end

    it 'is deleted' do
      expect { subject }.to change(Etablissement, :count).by(-1)
    end

    it { is_expected.to be_success }
  end

  context 'when the etablissement does not exist' do
    it 'returns a warning message' do
      warning_msg = subject[:warning]

      message = 'The etablissement with id (code_greffe: 1234, numero_gestion: 1A2B3C, id_etablissement: 1) does not exist in the database and cannot be deleted'
      expect(warning_msg).to eq(message)
    end

    it { is_expected.to be_success }
  end
end
