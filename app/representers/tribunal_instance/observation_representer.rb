class TribunalInstance::ObservationRepresenter < Representable::Decorator
  include Representable::XML

  property :code_greffe, reader: ->(doc:, **) { doc.parent.parent.parent[:cod] }
  property :code, as: :code_obs
  property :texte, as: :texte_obs
  property :date, as: :dat_obs
  property :numero, as: :num_obs
end
