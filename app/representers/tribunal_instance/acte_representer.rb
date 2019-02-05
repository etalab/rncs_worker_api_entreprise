class TribunalInstance::ActeRepresenter < Representable::Decorator
  include Representable::XML

  property :type
  property :nature
  property :date_depot, as: :dat_depot
  property :date_acte, as: :dat_acte
  property :numero_depot_manuel, as: :num_depot_manuel
end
