class TribunalInstance::AdresseRepresentantRepresenter < Representable::Decorator
  include Representable::XML

  property :residence,   as: :resid
  property :nom_voie,    as: :voie
  property :code_postal, as: :cp_bur
  property :localite,    as: :local
  property :pays
end
