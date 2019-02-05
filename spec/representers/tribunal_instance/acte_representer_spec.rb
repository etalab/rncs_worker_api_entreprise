require 'rails_helper'

describe TribunalInstance::ActeRepresenter, :representer do
  subject { entreprise_greffe_secondaire.actes.first }

  its(:type)                { is_expected.to eq 'AA' }
  its(:nature)              { is_expected.to eq 'DI' }
  its(:date_depot)          { is_expected.to eq '20170726' }
  its(:date_acte)           { is_expected.to eq 'L AN ZÉRO' }
  its(:numero_depot_manuel) { is_expected.to eq '2099' }
  its(:entreprise)          { is_expected.to be_a TribunalInstance::Entreprise }
end
