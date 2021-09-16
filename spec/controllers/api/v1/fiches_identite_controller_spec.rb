require 'rails_helper'

describe API::V1::FichesIdentiteController, type: :request do
  before { create :daily_update_with_completed_units }

  describe '#show' do
    subject do
      get "/v1/fiches_identite/#{siren}"
    end

    it_behaves_like 'handling siren errors'

    context 'valid siren' do
      before { create :dossier_entreprise_simple, siren: siren }
      let(:siren) { valid_siren }

      it 'returns 200' do
        subject

        expect(response).to have_http_status(200)
      end
    end
  end

  describe '#pdf' do
    subject do
      get "/v1/fiches_identite/#{siren}/pdf"
    end

    it_behaves_like 'handling siren errors'

    context 'valid siren' do
      before { create :dossier_entreprise_pm_many_reps, siren: siren }

      let(:siren) { valid_siren }

      it 'returns 200' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'has a binary PDF body' do
        subject

        pdf_magic_number = '25504446'
        response_magic_number = response.body.unpack("H*").first[0..7]

        expect(response_magic_number).to eq(pdf_magic_number)
      end

      it '[NOT A SPEC] generates a test PDF in /tmp' do
        subject
        File.open('./tmp/identite_entreprise_pm.pdf', 'wb') do |file|
          file.write response.body
        end
      end
    end

    # with current version (use git) it generate an edge case
    # of observation splitted on 2 pages handled by code
    it '[NOT A SPEC] generates a test PDF in /tmp' do
      create :dossier_entreprise_simple, siren: valid_siren
      get "/v1/fiches_identite/#{valid_siren}/pdf"

      File.open('./tmp/identite_entreprise_pp.pdf', 'wb') do |file|
        file.write response.body
      end
    end
  end
end
