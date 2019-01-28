class TribunalInstance::AdresseRepresentantPermanentRepresenter < Representable::Decorator
  include Representable::XML

  property :ligne_1, as: :adr
end
