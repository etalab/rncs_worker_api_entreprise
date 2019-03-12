require 'rails_helper'

describe API::InfosIdentiteEntrepriseController, type: :controller do
  before { create :daily_update_with_completed_units }

  describe '#show' do
    subject do
      get :show, params: { siren: siren }
    end

    it_behaves_like 'handling siren errors'

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

    it_behaves_like 'handling siren errors'

    context 'valid siren' do
      before { create :dossier_entreprise_pm_many_reps, siren: siren }

      let(:siren) { valid_siren }

      its(:status) { is_expected.to eq 200 }

      it 'has a binary PDF body' do
        mime = MimeMagic.by_magic(subject.body)
        expect(mime.child_of?('application/pdf')).to be_truthy
      end

      it '[NOT A SPEC] generates a test PDF in /tmp' do
        File.open('./tmp/identite_entreprise_pm.pdf', 'wb') do |file|
          file.write subject.body
        end
      end
    end

    # with current version (use git) it generate an edge case
    # of observation splitted on 2 pages handled by code
    it '[NOT A SPEC] generates a test PDF in /tmp' do
      create :dossier_entreprise_simple, siren: valid_siren
      get :pdf, params: { siren: valid_siren }

      File.open('./tmp/identite_entreprise_pp.pdf', 'wb') do |file|
        file.write response.body
      end
    end
  end
end
