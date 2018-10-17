class Siren
  include ActiveModel::Validations

  attr_reader :siren

  validates :siren, siren_format: true

  def initialize(siren = nil)
    @siren = siren
  end

  def to_s
    @siren
  end
end
