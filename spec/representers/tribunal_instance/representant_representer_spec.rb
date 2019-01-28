require 'rails_helper'

describe TribunalInstance::RepresentantRepresenter, :representer do
  describe 'first representant' do
    subject { entreprise_pm_representer.representants.first }

    it { is_expected.to be_a TribunalInstance::Representant }

    its(:qualite)                                { is_expected.to eq '1200' }
    its(:raison_sociale_ou_nom_ou_prenom)        { is_expected.to eq 'OULAC JOSEPH CHARLEMAGNE ALEXANDRE' }
    its(:nom_ou_denomination)                    { is_expected.to eq 'OULAC' }
    its(:prenoms)                                { is_expected.to eq 'JOSEPH CHARLEMAGNE ALEXANDRE' }
    its(:type_representant)                      { is_expected.to eq 'PP' }
    its(:date_creation)                          { is_expected.to be_nil }
    its(:date_modification)                      { is_expected.to be_nil }
    its(:date_radiation)                         { is_expected.to be_nil }
    its(:pseudonyme)                             { is_expected.to be_nil }
    its(:date_naissance)                         { is_expected.to eq '19480128' }
    its(:lieu_naissance)                         { is_expected.to eq 'POINTE A PITRE' }
    its(:pays_naissance)                         { is_expected.to be_nil }
    its(:nationalite)                            { is_expected.to be_nil }
    its(:nom_usage)                              { is_expected.to be_nil }
    its(:greffe_immatriculation)                 { is_expected.to be_nil }
    its(:siren_ou_numero_gestion)                { is_expected.to be_nil }
    its(:forme_juridique)                        { is_expected.to be_nil }
    its(:commentaire)                            { is_expected.to be_nil }
    its(:representant_permanent_nom)             { is_expected.to be_nil }
    its(:representant_permanent_prenoms)         { is_expected.to be_nil }
    its(:representant_permanent_nom_usage)       { is_expected.to be_nil }
    its(:representant_permanent_date_naissance)  { is_expected.to be_nil }
    its(:representant_permanent_ville_naissance) { is_expected.to be_nil }
    its(:representant_permanent_pays_naissance)  { is_expected.to be_nil }
    its(:entreprise_id)                          { is_expected.to be_nil }

    its(:adresse_representant) { is_expected.to be_a TribunalInstance::AdresseRepresentant }
  end

  describe 'second representant' do
    subject { entreprise_pm_representer.representants[1] }

    its(:adresse_representant_permanent) { is_expected.to be_a TribunalInstance::AdresseRepresentantPermanent }
  end
end
