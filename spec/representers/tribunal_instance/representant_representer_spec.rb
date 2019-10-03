require 'rails_helper'

describe TribunalInstance::RepresentantRepresenter, :representer do
  describe 'representant PP' do
    subject { entreprise_greffe_0000.representants.first }

    it { is_expected.to be_a TribunalInstance::Representant }

    its(:code_greffe)                            { is_expected.to eq '0000' }
    its(:qualite)                                { is_expected.to eq '1200' }
    its(:raison_sociale_ou_nom_ou_prenom)        { is_expected.to eq 'OULAC JOSEPH CHARLEMAGNE ALEXANDRE' }
    its(:nom_ou_denomination)                    { is_expected.to eq 'OULAC' }
    its(:prenoms)                                { is_expected.to eq 'JOSEPH CHARLEMAGNE ALEXANDRE' }
    its(:type_representant)                      { is_expected.to eq 'PP' }
    its(:date_creation)                          { is_expected.to eq 'L AN ZÉRO' }
    its(:date_modification)                      { is_expected.to eq 'HIER' }
    its(:date_radiation)                         { is_expected.to eq 'AVANT HIER' }
    its(:pseudonyme)                             { is_expected.to eq 'k3v1n75' }
    its(:date_naissance)                         { is_expected.to eq '19480128' }
    its(:ville_naissance)                        { is_expected.to eq 'POINTE A PITRE' }
    its(:pays_naissance)                         { is_expected.to eq 'MOON' }
    its(:nationalite)                            { is_expected.to eq 'TERRIEN' }
    its(:nom_usage)                              { is_expected.to eq 'CHARLO' }
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

  describe 'representant PM' do
    subject { entreprise_greffe_0000.representants[1] }

    its(:greffe_immatriculation)                 { is_expected.to eq 'PARIS' }
    its(:siren_ou_numero_gestion)                { is_expected.to eq '123456789' }
    its(:forme_juridique)                        { is_expected.to eq '9999' }
    its(:commentaire)                            { is_expected.to eq 'WESPISER PASCAL' }
    its(:representant_permanent_nom)             { is_expected.to eq 'REP NOM' }
    its(:representant_permanent_prenoms)         { is_expected.to eq 'REP PRENOM' }
    its(:representant_permanent_nom_usage)       { is_expected.to eq 'REP NOM USAGE' }
    its(:representant_permanent_date_naissance)  { is_expected.to eq 'REP DATE' }
    its(:representant_permanent_ville_naissance) { is_expected.to eq 'REP VILLE' }
    its(:representant_permanent_pays_naissance)  { is_expected.to eq 'REP PAYS' }

    its(:adresse_representant_permanent) { is_expected.to be_a TribunalInstance::AdresseRepresentantPermanent }
  end
end
