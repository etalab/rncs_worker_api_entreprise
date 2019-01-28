require 'rails_helper'

describe TribunalInstance::EtablissementRepresenter, :representer do
  subject { etablissement_representer }

  it { is_expected.to be_an TribunalInstance::Etablissement }

  its(:type_etablissement)             { is_expected.to eq 'PRI' }
  its(:siret)                          { is_expected.to eq '83011119100011' }
  its(:activite)                       { is_expected.to be_nil }
  its(:code_activite)                  { is_expected.to eq '6820B' }
  its(:enseigne)                       { is_expected.to be_nil }
  its(:nom_commercial)                 { is_expected.to be_nil }
  its(:date_debut_activite)            { is_expected.to be_nil }
  its(:origine_fonds)                  { is_expected.to be_nil }
  its(:type_activite)                  { is_expected.to be_nil }
  its(:date_cessation_activite)        { is_expected.to be_nil }
  its(:type_exploitation)              { is_expected.to be_nil }
  its(:precedent_exploitant_nom)       { is_expected.to be_nil }
  its(:precedent_exploitant_nom_usage) { is_expected.to be_nil }
  its(:precedent_exploitant_prenom)    { is_expected.to be_nil }
  its(:adresse)                        { is_expected.to be_a TribunalInstance::AdresseEtablissement }
end
