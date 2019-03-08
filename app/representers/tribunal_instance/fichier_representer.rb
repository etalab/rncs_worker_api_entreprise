class TribunalInstance::FichierRepresenter < Representable::Decorator
  include Representable::XML

  remove_namespaces!

  property :type, attribute: true

  collection :greffes,
    as: :grf,
    wrap: false,
    decorator: TribunalInstance::GreffeRepresenter,
    class: Struct.new(:code_greffe, :dossiers_entreprises, :entreprises)
end
