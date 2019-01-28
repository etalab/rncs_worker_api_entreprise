require 'rails_helper'

describe TribunalInstance::DossierEntrepriseRepresenter, :representer do
  subject { dossier_entreprise_pm_representer }

  it { is_expected.to be_a DossierEntreprise }

  its(:code_greffe)                   { is_expected.to eq '9712' }
  its(:nom_greffe)                    { is_expected.to eq 'fix me with a config file' }
  its(:numero_gestion)                { is_expected.to eq '2017D00184' }
  its(:siren)                         { is_expected.to eq '830111191' }
  its(:type_inscription)              { is_expected.to eq 'P' }
  its(:date_immatriculation)          { is_expected.to eq '20170607' }
  its(:date_premiere_immatriculation) { is_expected.to be_nil }
  its(:date_radiation)                { is_expected.to be_nil }
  its(:date_transfert)                { is_expected.to be_nil }
  its(:date_derniere_modification)    { is_expected.to eq '201601' }
  its(:numero_rcs)                    { is_expected.to eq 'D830111191' }
  its(:code_radiation)                { is_expected.to be_nil }
  its(:motif_radiation)               { is_expected.to be_nil }
end
