module CleanDataHelper
  class InappropriateBaseClass < StandardError; end;

  def self.included(base)
    if base.respond_to?(:attribute_names)
      override_default_attributes(base)
    else
      raise InappropriateBaseClass.new('base class must implement `attribute_names` class method')
    end
  end

  def self.override_default_attributes(model)
    model.attribute_names.each do |attr|
      define_method attr do |*args|
        original_data = super(*args)
        remove_leading_spaces_and_quotes(original_data)
      end
    end
  end

  def remove_leading_spaces_and_quotes(str)
    return str unless str.kind_of?(String)
    str.gsub(/\A[" ]+|[" ]+\z/, '')
  end

  def attributes(*args)
    raw_attributes = super(*args)
    raw_attributes.reduce({}) do |cleaned_attributes, (k, v)|
      cleaned_attributes[k] = remove_leading_spaces_and_quotes(v)
      cleaned_attributes
    end
  end
end
