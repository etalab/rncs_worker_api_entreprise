require 'rails_helper'

describe TribunalInstance::ObservationRepresenter, :representer do
  subject { entreprise_greffe_0000.observations.first }

  it { is_expected.to be_a TribunalInstance::Observation }

  its(:code_greffe) { is_expected.to eq '0000' }
  its(:code)        { is_expected.to eq 'J41' }
  its(:date)        { is_expected.to eq '20090908' }
  its(:numero)      { is_expected.to eq '1' }
  its(:entreprise)  { is_expected.to be_a TribunalInstance::Entreprise }
  its(:texte) { is_expected.to eq '7600;SELARL DAVID KOCH;;0004 RUE DU CONSEIL SOUVERAIN;;68000;COLMAR;;;0000;0000;;;' }
end
