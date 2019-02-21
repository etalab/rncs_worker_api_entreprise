require 'rails_helper'

describe ClearDataHelper do
  context 'when prepender class does not respond to .attribute_names' do
    let(:tested_class) do
      klass = Class.new do
        prepend ClearDataHelper

        def attr_test
          '   "  cou" cou   " '
        end
      end
      klass
    end

    it 'raises an error' do
      expect { tested_class }.to raise_error(ClearDataHelper::InappropriateBaseClass, 'base class must implement `attribute_names` class method')
    end
  end

  context 'when prepender class responds to .attribute_names' do
    let(:tested_class) do
      klass = Class.new do
        def self.attribute_names
          ['attr_test']
        end

        prepend ClearDataHelper

        def attr_test
          '   "  cou" cou   " '
        end
      end
      klass
    end

    it 'removes leading quotes and spaces from attributes' do
      filtered_attr = tested_class.new.attr_test

      expect(filtered_attr).to eq('cou" cou')
    end
  end
end
