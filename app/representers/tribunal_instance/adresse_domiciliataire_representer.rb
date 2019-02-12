class TribunalInstance::AdresseDomiciliataireRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe, reader: ->(doc:, **) { doc.parent.parent.parent[:cod] }
  property :ligne_1,         as: :adr
  property :residence,       as: :adr_resid
  property :numero_voie,     as: :adr_num_voie
  property :type_voie,       as: :adr_typ_voie
  property :nom_voie,        as: :adr_nom_voie
  property :code_postal,     as: :adr_cp
  property :bureau_et_cedex, as: :adr_bur
end
