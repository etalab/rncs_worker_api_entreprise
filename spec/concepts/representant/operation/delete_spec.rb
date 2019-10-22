require 'rails_helper'

describe Representant::Operation::Delete do
  let(:data) do
    {
      code_greffe:     '1234',
      numero_gestion:  '1A2B3C',
      id_representant: '1',
      qualite:         'Ghost'
    }
  end

  subject { described_class.call(data: data) }

  context 'when the representant is found' do
    before do
      create(
        :representant,
        code_greffe:     '1234',
        numero_gestion:  '1A2B3C',
        id_representant: '1',
        qualite:         'Ghost'
      )
    end

    it 'is deleted' do
      expect { subject }.to change(Representant, :count).by(-1)
    end

    it { is_expected.to be_success }
  end

  context 'when the representant does not exist' do
    it 'returns a warning message' do
      warning_msg = subject[:warning]

      expect(warning_msg).to eq('The representant with id (code_greffe: 1234, numero_gestion: 1A2B3C, id_representant: 1, qualite: Ghost) does not exist in the database and cannot be deleted')
    end

    it { is_expected.to be_success }
  end
end
