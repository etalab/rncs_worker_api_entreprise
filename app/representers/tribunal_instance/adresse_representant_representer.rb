class TribunalInstance::AdresseRepresentantRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe, reader: ->(doc:, **) { doc.parent.parent.parent.parent[:cod] }
  property :residence,   as: :resid
  property :nom_voie,    as: :voie
  property :code_postal, as: :cp_bur
  property :localite,    as: :local
  property :pays
end
