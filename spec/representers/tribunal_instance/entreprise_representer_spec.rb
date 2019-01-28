require 'rails_helper'

describe TribunalInstance::EntrepriseRepresenter, :representer do
  describe 'Personne Morale' do
    subject { entreprise_pm_representer }

    it { is_expected.to be_a TribunalInstance::Entreprise }

    its(:code_greffe)                 { is_expected.to eq '9712' }
    its(:siren)                       { is_expected.to eq '830111191' }
    its(:numero_gestion)              { is_expected.to eq '2017D00184' }
    its(:denomination)                { is_expected.to eq 'SCI ARSEJO' }
    its(:nom_patronyme)               { is_expected.to be_nil }
    its(:prenoms)                     { is_expected.to be_nil }
    its(:forme_juridique)             { is_expected.to eq '6540' }
    its(:associe_unique)              { is_expected.to eq '1' }
    its(:date_naissance)              { is_expected.to be_nil }
    its(:ville_naissance)             { is_expected.to be_nil }
    its(:code_activite)               { is_expected.to eq '6820B' }
    its(:activite_principale)         { is_expected.to be_nil }
    its(:capital)                     { is_expected.to eq '300000' }
    its(:devise)                      { is_expected.to eq 'EUR' }
    its(:capital_actuel)              { is_expected.to be_nil }
    its(:duree_pm)                    { is_expected.to be_nil }
    its(:date_cloture)                { is_expected.to be_nil }
    its(:nom_usage)                   { is_expected.to be_nil }
    its(:pseudonyme)                  { is_expected.to be_nil }
    its(:sigle)                       { is_expected.to be_nil }
    its(:nom_commercial)              { is_expected.to be_nil }
    its(:greffe_siege)                { is_expected.to be_nil }
    its(:status_edition_extrait)      { is_expected.to be_nil }
    its(:date_cloture_exceptionnelle) { is_expected.to be_nil }
    its(:domiciliataire_nom)          { is_expected.to be_nil }
    its(:domiciliataire_rcs)          { is_expected.to be_nil }
    its(:eirl)                        { is_expected.to be_nil }
    its(:dap_denomnimation)           { is_expected.to be_nil }
    its(:dap_object)                  { is_expected.to be_nil }
    its(:dap_date_cloture)            { is_expected.to be_nil }
    its(:auto_entrepreneur)           { is_expected.to be_nil }
    its(:economie_sociale_solidaire)  { is_expected.to be_nil }

    its(:adresse_siege)               { is_expected.to be_a TribunalInstance::AdresseSiege }
    its(:adresse_domiciliataire)      { is_expected.to be_a TribunalInstance::AdresseDomiciliataire }
    its(:adresse_dap)                 { is_expected.to be_nil }

    its(:etablissements) { are_expected.to all be_a TribunalInstance::Etablissement }
    its(:etablissements) { is_expected.to have_attributes(size: 2) }
    its(:etablissements) { are_expected.to all have_attributes type_etablissement: /(PRI|SEC)/ }

    its(:representants) { are_expected.to all be_a TribunalInstance::Representant }
    its(:representants) { is_expected.to have_attributes(size: 2) }
    its(:representants) { are_expected.to all have_attributes type_representant: /(PM|PP)/ }
  end

  describe 'Personne Physique' do
    subject { entreprise_pp_representer }

    its(:prenoms)         { is_expected.to eq 'GLADYS AMEDEE' }
    its(:forme_juridique) { is_expected.to eq '1200' }
    its(:denomination)    { is_expected.to be_nil }
    its(:nom_patronyme)   { is_expected.to eq 'ALEXIS' }
    its(:adresse_dap)     { is_expected.to be_a TribunalInstance::AdresseDAP }
  end
end
