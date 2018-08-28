require 'rails_helper'

describe DataSource::Stock::TribunalCommerce::Unit::Operation::Import do
  let(:params) do
    [
      { loader: loader_for(:pm_stock_file), path: path_for(:pm_stock_file) }
    ]
  end

  let(:task_container) do
    Class.new(Trailblazer::Operation) do
      step DataSource::Stock::TribunalCommerce::Unit::Operation::Import
    end
  end

  subject { task_container.call(stock_files: params) }
end
