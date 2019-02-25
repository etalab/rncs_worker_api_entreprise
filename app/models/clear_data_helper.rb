module ClearDataHelper
  class InappropriateBaseClass < StandardError; end;

  def self.prepended(base)
    if base.respond_to?(:attribute_names)
      override_default_attributes(base)
    else
      raise InappropriateBaseClass.new('base class must implement `attribute_names` class method')
    end
  end

  def self.override_default_attributes(model)
    model.attribute_names.each do |attr|
      unless ['id', 'created_at', 'updated_at'].include?(attr)
        define_method attr do |*args|
          original_data = super(*args)
          remove_leading_spaces_and_quotes(original_data)
        end
      end
    end
  end

  def remove_leading_spaces_and_quotes(str)
    return str if str.class != String
    str.gsub(/\A[" ]+|[" ]+\z/, '')
  end

  def attributes(*args)
    raw_attributes = super(*args)
    clean_attributes = {}
    raw_attributes.each do |k, v|
      clean_attributes[k] = remove_leading_spaces_and_quotes(v)
    end
    clean_attributes
  end
end
