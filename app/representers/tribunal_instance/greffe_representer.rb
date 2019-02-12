class TribunalInstance::GreffeRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe, as: :cod, attribute: true

  collection :dossiers_entreprises,
    as: :societe,
    wrap: false,
    decorator: TribunalInstance::DossierEntrepriseRepresenter,
    class: DossierEntreprise

  collection :entreprises,
    as: :societe,
    wrap: false,
    decorator: TribunalInstance::EntrepriseRepresenter,
    class: TribunalInstance::Entreprise
end
