require 'rails_helper'

describe DossierEntreprise::Operation::FetchImmatriculationPrincipale do
  subject { described_class.call(siren: siren) }
  let(:siren) { '123456789' }

  context 'when only one immatriculation principale found' do
    let!(:dossier) { create(:dossier_entreprise, siren: siren) }

    its(:success?) { is_expected.to eq(true) }
    its([:dossier_principal]) { is_expected.to eq dossier }
    its([:error]) { is_expected.to be_nil }
  end

  context 'when no immatriculation principale found' do
    context 'but has some immatriculation secondaire' do
      let!(:dossier) { create(:dossier_entreprise, siren: siren, type_inscription: 'S') }

      its(:success?) { is_expected.to eq(false) }
      its([:dossier_principal]) { is_expected.to be_nil }
      its([:error]) { is_expected.to eq "Immatriculation principale non trouvée pour le siren #{siren}." }
    end

    context 'and has no immatriculation secondaire' do
      its(:success?) { is_expected.to eq(false) }
      its([:dossier_principal]) { is_expected.to be_nil }
      its([:error]) { is_expected.to eq "Aucune immatriculation trouvée pour le siren #{siren}" }
    end
  end

  context 'when mutliple immatriculation principale found' do
    let!(:new_dossier) { create(:dossier_entreprise, siren: siren, date_immatriculation: '2000-01-01') }

    describe 'returns the latest' do
      let!(:old_dossier) { create(:dossier_entreprise, siren: siren, date_immatriculation: '1999-12-31') }

      its(:success?) { is_expected.to eq(true) }
      its([:dossier_principal]) { is_expected.to eq new_dossier }
      its([:error]) { is_expected.to be_nil }
    end

    describe 'fails when at least one nil/blank date_immatriculation' do
      let!(:old_dossier) { create(:dossier_entreprise, siren: siren, date_immatriculation: '') }

      its(:success?) { is_expected.to eq(false) }
      its([:dossier_principal]) { is_expected.to be_nil }
      its([:error]) { is_expected.to eq "Impossible de constituer la fiche pour le SIREN #{siren}." }
    end
  end
end
