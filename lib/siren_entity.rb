class SirenEntity
  attr_accessor :siren
  attr_reader :infos

  def initialize(siren)
    @siren = siren
    @infos = {}
  end

  def compute
    self.methods.select{ |m| m =~ /compute_/}.each do |compute_method|
      self.send compute_method
    end

    infos
  end

  def compute_observations
    infos[:observations] ||= all_dossiers_entreprises.map(&:observations).flatten
  end

  def compute_representants
    infos[:representants] ||= all_dossiers_entreprises.map(&:representants).flatten
  end

  def compute_etablissement_types
    all_etablissements.each do |etablissement|
      infos[:etablissements_types] ||= {}
      infos[:etablissements_types][etablissement.type_etablissement.to_sym] ||= 0
      infos[:etablissements_types][etablissement.type_etablissement.to_sym] += 1
    end
  end

  private
  def all_dossiers_entreprises
    @all_dossiers_entreprises ||= DossierEntreprise.where(siren: siren).includes(:personne_morale, :personne_physique, :observations, :representants, :observations)
  end

  def all_etablissements
    @all_etablissements ||= all_dossiers_entreprises.map(&:etablissements).flatten
  end
end
