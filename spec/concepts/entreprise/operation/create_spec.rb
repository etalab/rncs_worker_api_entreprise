require 'rails_helper'

describe Entreprise::Operation::Create do
  let(:create_params) do
    {
      :code_greffe=>'101',
      :nom_greffe=>'Bourg-en-Bresse',
      :numero_gestion=>'2015B01079',
      :siren=>'813543063',
      :type_inscription=>'P',
      :date_immatriculation=>'2015-09-17',
      :date_premiere_immatriculation=>'2015-09-17',
      :date_radiation=>'',
      :date_transfert=>'',
      :sans_activite=>'',
      :date_debut_activite=>'2015-10-01',
      :date_debut_premiere_activite=>'2015-10-01',
      :date_cessation_activite=>'',
      :date_derniere_modification=>'2015-09-17',
      :libelle_derniere_modification=>'Création'
    }
  end
  subject { described_class.call(params: create_params) }

  context 'when params are valid' do
    it 'is successful' do
      expect(subject).to be_success
    end
    it 'saves the entreprise' do
      expect {subject}.to change(Entreprise, :count).by(1)
    end
  end

  context 'when params are invalid' do
    let(:errors) { subject['result.contract.default'].errors[field_name] }

    describe ':siren' do
      let(:field_name) { :siren }
      it 'is required' do
        create_params[:siren] = nil

        expect(subject).to be_failure
        expect(errors).to include('must be filled')
      end
    end
  end
end
