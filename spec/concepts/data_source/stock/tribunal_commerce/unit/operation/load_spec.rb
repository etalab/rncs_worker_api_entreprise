require 'rails_helper'

describe DataSource::Stock::TribunalCommerce::Unit::Operation::Load do
  # it 'calls unzip operation'

  # let(:unit_example) { path_for(:tc_stock_unit) }

  # after do
  #   dest_dir = name_for(:tc_stock_unit)
  #   FileUtils.rm_rf(Rails.root.join('tmp', dest_dir))
  # end

  # TODO create a real csv test suite with valid associations between records
  #describe 'extracted archive content' do
  #  subject { described_class.call(stock_unit_path: unit_example) }
  #  let(:stock_files) { subject[:raw_stock_files] }

  #  it 'contains 7 stock files' do
  #    expect(stock_files.size).to eq(7)
  #  end

  #  describe 'stock files type' do
  #    def has_stock?(stock_type)
  #      stock_files.any? { |e| e.include?(stock_type) }
  #    end

  #    it 'has a personne morale stock file' do
  #      expect(has_stock?('1_PM')).to eq(true)
  #    end

  #    it 'has a personne physique stock file' do
  #      expect(has_stock?('3_PP')).to eq(true)
  #    end

  #    it 'has a representant stock file' do
  #      expect(has_stock?('5_rep')).to eq(true)
  #    end

  #    it 'has an etablissement stock file' do
  #      expect(has_stock?('8_ets')).to eq(true)
  #    end

  #    it 'has an observations stock file' do
  #      expect(has_stock?('11_obs')).to eq(true)
  #    end

  #    it 'has an actes stock file' do
  #      expect(has_stock?('12_actes')).to eq(true)
  #    end

  #    it 'has a comptes_annuels stock file' do
  #      expect(has_stock?('13_comptes_annuels')).to eq(true)
  #    end
  #  end
  #end

  it 'orders files for import' do

  end
end
