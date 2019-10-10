require 'rails_helper'

describe TribunalInstance::EtablissementRepresenter, :representer do
  subject { etablissement_representer }

  it { is_expected.to be_an(TribunalInstance::Etablissement) }

  its(:code_greffe)                    { is_expected.to eq('9712') }
  its(:type_etablissement)             { is_expected.to eq('PRI') }
  its(:siret)                          { is_expected.to eq('83011119100011') }
  its(:activite)                       { is_expected.to eq('NE RIEN FAIRE') }
  its(:code_activite)                  { is_expected.to eq('6820B') }
  its(:enseigne)                       { is_expected.to eq('ENSEIGNE A') }
  its(:nom_commercial)                 { is_expected.to eq('NOM COMMERCIAL A') }
  its(:date_debut_activite)            { is_expected.to eq('L AN ZÉRO') }
  its(:origine_fonds)                  { is_expected.to eq('MA POCHE') }
  # A (ambulant) ou F (forain) + S (saisonnier) ou P (permanent)
  its(:type_activite)                  { is_expected.to eq('FS') }
  its(:date_cessation_activite)        { is_expected.to eq('JAMAIS') }
  its(:type_exploitation)              { is_expected.to eq('JE NE SAIS PAS') }
  its(:precedent_exploitant_nom)       { is_expected.to eq('NOM PRECEDENT EXPLOITANT') }
  its(:precedent_exploitant_nom_usage) { is_expected.to eq('NOM USAGE') }
  its(:precedent_exploitant_prenom)    { is_expected.to eq('PRENOM PRECEDENT EXPLOITANT') }
  its(:adresse)                        { is_expected.to be_a(TribunalInstance::AdresseEtablissement) }
end
