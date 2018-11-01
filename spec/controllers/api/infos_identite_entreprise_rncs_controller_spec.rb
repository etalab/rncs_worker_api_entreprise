require 'rails_helper'

describe API::InfosIdentiteEntrepriseRNCSController, type: :controller do

  subject do
    get :show, params: { siren: siren }
  end

  context 'ill formatted siren ' do
    let(:siren) { invalid_siren }

    it 'prompts error 400' do
      expect(subject.status).to eq(400)
    end
  end


  context 'valid siren' do
    before { create :dossier_entreprise_simple, siren: siren }
    let(:siren) { valid_siren }

    it 'returns 200' do
      expect(subject.status).to eq(200)
    end

  end

end
