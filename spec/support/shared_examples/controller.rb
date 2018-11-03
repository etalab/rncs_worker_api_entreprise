shared_examples 'handling errors' do
    context 'when siren is invalid' do
      let(:siren) { invalid_siren }

  its(:status) { is_expected.to eq 422 }
    end

    context 'non existent siren' do
      let(:siren) { non_existent_siren }

      its(:status) { is_expected.to eq 404 }
    end
end
