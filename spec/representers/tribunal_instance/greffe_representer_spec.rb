require 'rails_helper'

describe TribunalInstance::GreffeRepresenter, :representer do
  shared_examples 'greffe with dossiers' do |code_greffe:|
    it { is_expected.to be_a Struct }
    it { is_expected.to have_attributes code_greffe: code_greffe }

    its(:dossiers_entreprises)  { are_expected.to all be_a DossierEntreprise }
    its(:entreprises)           { are_expected.to all be_a TribunalInstance::Entreprise }
  end

  describe 'inscriptions principales' do
    subject { greffe_principal }

    it_behaves_like 'greffe with dossiers', code_greffe: '9712'
  end

  describe 'inscriptions secondaires' do
    subject { greffe_secondaire }

    it_behaves_like 'greffe with dossiers', code_greffe: '0000'
  end
end
