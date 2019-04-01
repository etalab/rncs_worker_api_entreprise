require 'rails_helper'

describe TribunalInstance::DailyUpdate::Unit::Task::PersistRcs do
  subject { described_class.call dossier: dossier, logger: logger }

  let(:logger) { instance_double(Logger).as_null_object }
  let(:path) { Rails.root.join 'spec/fixtures/titmc/xml/flux_RCS.xml' }

  let(:greffe) do
    greffe = TribunalInstance::FichierRepresenter
      .new(TribunalInstance::Fichier.new)
      .from_xml(File.read(path.to_s))
      .greffes.first
  end

  let(:dossiers) do
    greffe.dossiers_entreprises.each_with_index do |dossier, index|
      dossier.titmc_entreprise = greffe.entreprises[index]
    end

    greffe.dossiers_entreprises
  end

  shared_examples 'dossier persisted' do
    it { is_expected.to be_success }

    it 'logs' do
      expect(logger).to receive(:info).with(/Dossier persisted id: .+/)
      subject
    end

    its([:dossier]) { is_expected.to be_persisted }

    it 'persists adresse siège' do
      expect { subject }.to change(TribunalInstance::AdresseSiege, :count).by 1
    end

    it 'persists adresse representant' do
      expect { subject }.to change(TribunalInstance::AdresseRepresentant, :count).by 1
    end

    it 'persists entreprise' do
      expect { subject }.to change(TribunalInstance::Entreprise, :count).by 1
    end

    it 'persists établissement' do
      expect { subject }.to change(TribunalInstance::Etablissement, :count).by 1
    end

    it 'persists observations' do
      expect { subject }.to change(TribunalInstance::Observation, :count).by 2
    end

    it 'persists représentant' do
      expect { subject }.to change(TribunalInstance::Representant, :count).by 1
    end
  end

  context 'when dossier is not found' do
    let(:dossier) { dossiers.find { |d| d.siren == '819356163' } }

    it 'logs' do
      expect(logger).to receive(:info).with('No dossier found, creating it...')
      subject
    end

    it_behaves_like 'dossier persisted'
  end

  context 'when dossier already exists' do
    let!(:existing_dossier) do
      create :dossier_entreprise,
        code_greffe: dossier.code_greffe,
        numero_gestion: dossier.numero_gestion,
        siren: dossier.siren
    end

    let(:dossier) { dossiers.find { |d| d.siren == '819356163' } }

    it 'logs' do
      expect(logger).to receive(:info).with('Existing dossier found, deleting it...')
      subject
    end

    it 'destroy existing dossier' do
      subject
      expect { existing_dossier.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it_behaves_like 'dossier persisted'
  end

  context 'when key numéro gestion is missing' do
    let(:dossier) { dossiers.find { |d| d.siren == 'missing numero gestion' } }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with(/Numéro gestion is missing for this dossier siren: .+/)
      subject
    end
  end

  context 'when key siren is missing' do
    let(:dossier) { dossiers.find { |d| d.numero_gestion == 'missing siren' } }

    it { is_expected.to be_failure }

    it 'logs an error' do
      expect(logger).to receive(:error).with(/Siren is missing for this dossier numéro gestion: .+/)
      subject
    end
  end
end
