require 'rails_helper'

describe TribunalInstance::BilanRepresenter, :representer do
  subject { entreprise_greffe_secondaire.bilans.first }

  its(:code_greffe)                        { is_expected.to eq '0000' }
  its(:date_cloture_annee)                 { is_expected.to eq '2013' }
  its(:date_cloture_jour_mois)             { is_expected.to eq '3006' }
  its(:date_depot)                         { is_expected.to eq '20150109' }
  its(:confidentialite_document_comptable) { is_expected.to eq '1' }
  its(:confidentialite_compte_resultat)    { is_expected.to eq '0' }
  its(:numero)                             { is_expected.to eq '29' }
  its(:duree_exercice)                     { is_expected.to eq '12' }
  its(:entreprise)                         { is_expected.to be_a TribunalInstance::Entreprise }
end
