require 'rails_helper'

describe TribunalInstance::GreffeRepresenter, :representer do
  describe 'inscriptions principales' do
    subject { greffe_principal }

    it { is_expected.to be_a Struct }
    it { is_expected.to have_attributes code_greffe: '9712' }

    its(:dossiers_entreprises)  { are_expected.to all be_a DossierEntreprise }
    its(:entreprises)           { are_expected.to all be_a TribunalInstance::Entreprise }
  end

  describe 'inscriptions secondaires' do
    # TODO: code greffe 0000
  end
end
