class SirenFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    validate_length_and_digits_only(record, attribute, value)
    validate_structure(record, attribute, value)
  end

  def validate_length_and_digits_only(record, attribute, value)
    record.errors.add(attribute, :format, message: '9 digits only') unless value =~ /^\d{9}$/
  end

  def validate_structure(record, attribute, value)
    unless !value.nil? && valid_checksum(value)
      record.errors.add(attribute, :checksum, message: 'must have luhn_checksum ok')
    end
  end

  private

  def valid_checksum(value)
    (luhn_checksum(value) % 10) == 0
  end

  def luhn_checksum(value)
    accum = 0
    value.reverse.each_char.map(&:to_i).each_with_index do |digit, index|
      t = index.even? ? digit : digit * 2
      t -= 9 if t >= 10
      accum += t
    end
    accum
  end
end
