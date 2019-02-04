require 'rails_helper'

describe TribunalCommerce::Helper::DataFile do
  let(:includer) do
    class A
      include TribunalCommerce::Helper::DataFile
    end
    A.new
  end

  describe '#fetch_from_folder' do
    it 'returns absolute files path inside the folder'
  end

  describe '#parse_stock_filename' do

  end

  describe '#parse_flux_filename' do
    subject { includer.parse_flux_filename(["/random/path/#{filename}"]) }

    context 'with a valid filename' do
      let(:filename) { '0101_1_20170512_112544_6_rep_nouveau_modifie_EVT.csv' }

      it 'returns a valid hash for each files' do
        expect(subject).to contain_exactly(a_hash_including(
          code_greffe: '0101',
          run_order: 6,
          label: 'rep_nouveau_modifie_EVT',
          path: a_string_ending_with('0101_1_20170512_112544_6_rep_nouveau_modifie_EVT.csv')
        ))
      end
    end

    context 'with an invalid filename' do
      let(:filename) { 'inval1d_filename.txt' }

      it 'raises UnexpectedFilename' do
        expect { subject }
          .to raise_error(
            TribunalCommerce::Helper::DataFile::UnexpectedFilename,
            'Cannot parse filename : "inval1d_filename.txt" does not match the expected pattern'
          )
      end
    end
  end

  describe '#parse_stock_filename' do
    subject { includer.parse_stock_filename(["/random/path/#{filename}"]) }

    context 'with a valid filename' do
      let(:filename) { '0101_S2_20180824_5_rep.csv' }

      it 'returns a valid hash for each files' do
        expect(subject).to contain_exactly(a_hash_including(
          code_greffe: '0101',
          run_order: 5,
          label: 'rep',
          path: a_string_ending_with('0101_S2_20180824_5_rep.csv')
        ))
      end
    end

    context 'with an invalid filename' do
      let(:filename) { 'inval1d_filename.txt' }

      it 'raises UnexpectedFilename' do
        expect { subject }
          .to raise_error(
            TribunalCommerce::Helper::DataFile::UnexpectedFilename,
            'Cannot parse filename : "inval1d_filename.txt" does not match the expected pattern'
          )
      end
    end
  end

  describe '#map_import_worker' do
    def worker(label)
      result = includer.map_import_worker([{ label: label }])
      result.first.fetch(:import_worker)
    end

    context 'when label is known' do
      it 'maps PM file' do
        expect(worker('PM')).to eq(DataSource::File::PM::Operation::Import)
      end

      it 'maps PM_EVT file' do
        expect(worker('PM_EVT')).to eq(TribunalCommerce::File::PMEvent::Operation::Import)
      end

      it 'maps PP file' do
        expect(worker('PP')).to eq(DataSource::File::PP::Operation::Import)
      end

      it 'maps PP_EVT file' do
        expect(worker('PP_EVT')).to eq(TribunalCommerce::File::PPEvent::Operation::Import)
      end

      it 'maps rep file' do
        expect(worker('rep')).to eq(DataSource::File::Rep::Operation::Import)
      end

      it 'maps rep_nouveau_modifie_EVT file' do
        expect(worker('rep_nouveau_modifie_EVT')).to eq(TribunalCommerce::File::RepNouveauModifie::Operation::Import)
      end

      it 'maps rep_partant_EVT file' do
        expect(worker('rep_partant_EVT')).to eq(TribunalCommerce::File::RepPartant::Operation::Import)
      end

      it 'maps ets file' do
        expect(worker('ets')).to eq(DataSource::File::Ets::Operation::Import)
      end

      it 'maps ets_nouveau_modifie_EVT file' do
        expect(worker('ets_nouveau_modifie_EVT')).to eq(TribunalCommerce::File::EtsNouveauModifie::Operation::Import)
      end

      it 'maps ets_supprime_EVT file' do
        expect(worker('ets_supprime_EVT')).to eq(TribunalCommerce::File::EtsSupprime::Operation::Import)
      end

      it 'maps obs file' do
        expect(worker('obs')).to eq(DataSource::File::Obs::Operation::Import)
      end
    end

    context 'when label is unknown' do
      it 'raises UnknownFileLabel exception with an unknown label' do
        expect { worker('invalid label') }
          .to raise_error(
            TribunalCommerce::Helper::DataFile::UnknownFileLabel,
            'Unknown file label "invalid label"'
        )
      end
    end
  end
end
