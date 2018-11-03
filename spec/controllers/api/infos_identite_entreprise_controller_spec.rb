require 'rails_helper'

describe API::InfosIdentiteEntrepriseController, type: :controller do
  describe '#show' do
    subject do
      get :show, params: { siren: siren }
    end

    it_behaves_like 'handling errors'

    context 'valid siren' do
      before { create :dossier_entreprise_simple, siren: siren }
      let(:siren) { valid_siren }

      it 'returns 200' do
        expect(subject.status).to eq(200)
      end
    end
  end

  describe '#pdf' do
    subject do
      get :pdf, params: { siren: siren }
    end

    it_behaves_like 'handling errors'

    context 'valid siren' do
      before { create :dossier_entreprise_simple, siren: siren }

      let(:siren) { valid_siren }

      its(:status) { is_expected.to eq 200 }

      it 'has a binary PDF body' do
        mime = MimeMagic.by_magic(subject.body)
        expect(mime.child_of?('application/pdf')).to be_truthy
      end
    end
  end
end
