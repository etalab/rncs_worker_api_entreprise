class TribunalInstance::AdresseSiegeRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe, reader: ->(doc:, **) { doc.parent.parent.parent[:cod] }

  nested :adr_1 do
    property :ligne_1,         as: :nom_1
    property :ligne_2,         as: :nom_2
    property :residence,       as: :resid
    property :numero_voie,     as: :num_voie
    property :type_voie,       as: :type_voie
    property :nom_voie,        as: :nom_voie
    property :localite,        as: :local
    property :code_postal,     as: :cp
    property :bureau_et_cedex, as: :bur_cdx
    property :pays
  end
end
