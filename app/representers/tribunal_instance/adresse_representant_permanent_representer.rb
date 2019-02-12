class TribunalInstance::AdresseRepresentantPermanentRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe, reader: ->(doc:, **) { doc.parent.parent.parent.parent.parent[:cod] }
  property :ligne_1, as: :adr
end
