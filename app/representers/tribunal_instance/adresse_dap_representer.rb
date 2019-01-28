class TribunalInstance::AdresseDAPRepresenter < Representable::Decorator
  include Representable::XML

  nested :adr do
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
