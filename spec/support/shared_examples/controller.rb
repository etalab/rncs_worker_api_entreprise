shared_examples 'handling siren errors' do
  context 'when siren is invalid' do
    let(:siren) { invalid_siren }

    its(:status) { is_expected.to eq 422 }

    it 'returns 422 with error message' do
      json = JSON.parse subject.body
      expect(json).to include_json error: 'Siren invalide'
    end
  end

  context 'non existent siren' do
    let(:siren) { non_existent_siren }

    its(:status) { is_expected.to eq 404 }

    it 'returns 404 with error message' do
      json = JSON.parse subject.body
      expect(json).to include_json error: 'Aucun dossier trouvé'
    end
  end
end
