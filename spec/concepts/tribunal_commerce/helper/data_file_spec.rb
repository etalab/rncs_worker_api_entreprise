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
end
