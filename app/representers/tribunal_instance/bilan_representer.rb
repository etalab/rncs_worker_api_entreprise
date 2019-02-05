class TribunalInstance::BilanRepresenter < Representable::Decorator
  include Representable::XML

  property :date_cloture_annee, as: :date_cloture_aa
  property :date_cloture_jour_mois, as: :dat_cloture_jjmm
  property :date_depot, as: :dat_depot
  property :confidentialite_document_comptable, as: :confid_ind
  property :confidentialite_compte_resultat, as: :confid_ind_CR
  property :numero, as: :num_depot
  property :duree_exercice
end
