class TribunalInstance::GreffeRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe, as: :cod, attribute: true

  collection :dossiers_entreprises,
    as: :societe,
    wrap: false,
    decorator: TribunalInstance::DossierEntrepriseRepresenter,
    class: DossierEntreprise,
    if: ->(represented:, **) do
      represented.code_greffe != '0000'
    end

  collection :entreprises,
    as: :societe,
    wrap: false,
    decorator: TribunalInstance::EntrepriseRepresenter,
    class: TribunalInstance::Entreprise,
    if: ->(represented:, **) do
      represented.code_greffe != '0000'
    end

  # TODO: code_greffe == '0000'
end
