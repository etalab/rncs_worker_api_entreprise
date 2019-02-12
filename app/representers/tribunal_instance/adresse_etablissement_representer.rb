class TribunalInstance::AdresseEtablissementRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe, reader: ->(doc:, **) { doc.parent.parent.parent.parent[:cod] }

  property :ligne_1,         as: :part_1
  property :ligne_2,         as: :part_2
  property :residence,       as: :resid
  property :nom_voie,        as: :voie
  property :localite,        as: :local
  property :code_postal,     as: :cp_bur
end
