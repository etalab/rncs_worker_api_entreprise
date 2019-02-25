require 'rails_helper'

describe CleanDataHelper do
  let(:stubbed_AR_base) do
    klass = Class.new do
      def self.attribute_names
        ['attr_test']
      end

      def attr_test
        '   "  cou" cou   " '
      end

      def attributes
        { attr_test: '   "  cou" cou   " ' }
      end
    end
    klass
  end

  context 'when includind class does not respond to .attribute_names' do
    let(:tested_class) do
      klass = Class.new do
        include CleanDataHelper
      end
      klass
    end

    it 'raises an error' do
      expect { tested_class }.to raise_error(CleanDataHelper::InappropriateBaseClass, 'base class must implement `attribute_names` class method')
    end
  end

  context 'when including class responds to .attribute_names' do
    let(:tested_class) do
      klass = Class.new(stubbed_AR_base) do
        include CleanDataHelper
      end
      klass
    end

    it 'removes leading quotes and spaces on attribute\'s reader call' do
      filtered_attr = tested_class.new.attr_test

      expect(filtered_attr).to eq('cou" cou')
    end

    it 'removes leading quotes and spaces on #atributes method call' do
      filtered_attr = tested_class.new.attributes

      expect(filtered_attr).to match({ attr_test: 'cou" cou' })
    end
  end
end
