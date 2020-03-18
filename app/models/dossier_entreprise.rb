class DossierEntreprise < ApplicationRecord
  has_one :personne_morale, dependent: :destroy
  has_one :personne_physique, dependent: :destroy
  has_many :representants, dependent: :destroy
  has_many :etablissements, dependent: :destroy
  has_many :observations, dependent: :destroy
  has_one :titmc_entreprise, dependent: :destroy, class_name: 'TribunalInstance::Entreprise'
  has_one :titmc_entreprise, dependent: :destroy, class_name: 'TribunalInstance::Entreprise'

  FRENCH_DATE_FORMAT = /\d{2}(-|\/)\d{2}(-|\/)\d{4}/
  US_DATE_FORMAT = /\d{4}(-|\/)\d{2}(-|\/)\d{2}/
  DATE_FORMAT = /(#{FRENCH_DATE_FORMAT}|#{US_DATE_FORMAT})/

  validates_associated :personne_morale, if: :en_activite?
  validates_associated :personne_physique, if: :en_activite?

  validates :code_greffe, presence: true, numericality: true
  validates :numero_gestion, presence: true
  validates :siren, presence: true, siren_format: true
  validates :nom_greffe, presence: true
  validates :date_immatriculation, format: { with: DATE_FORMAT }, presence: true
  validates :type_inscription, inclusion: { in: %w[P S] }
  validate :une_seule_inscription_principale,
           :un_seul_etab_principal,
           :adresse_etab_principal,
           :activite_etab_principal,
           :date_debut_activite_etab_principal

  def une_seule_inscription_principale
    return if inscription_secondaire?

    dossiers = DossierEntreprise.where(
      siren: siren,
      type_inscription: 'P',
      date_radiation: nil
    )
    return if dossiers.count == 1

    errors.add(:type_inscription, "#{dossiers.count} inscriptions principales trouvées non-radiées")
  end

  def un_seul_etab_principal
    return if etabs_pri.count == 1

    errors.add(:uniq_etablissement_principal, "#{etabs_pri.count} établissement(s) principal(aux) trouvé(s)")
  end

  def adresse_etab_principal
    etab_pri = etabs_pri.first
    return if etab_pri.nil?
    return if (etab_pri.adresse_ligne_1 || etab_pri.adresse_ligne_2) &&
      etab_pri.adresse_code_postal

    errors.add(:adresse_etablissement_principal, 'Adresse incomplète ligne 1, 2 ou code postal manquant')
  end

  def activite_etab_principal
    etab_pri = etabs_pri.first
    return if etab_pri.nil?
    return unless etab_pri.activite.nil? || etab_pri.activite.blank?

    errors.add(:activite_etablissement_principal, 'Activité non renseignée')
  end

  def date_debut_activite_etab_principal
    etab_pri = etabs_pri.first
    return if etab_pri.nil?
    return unless etab_pri.date_debut_activite.nil? || etab_pri.date_debut_activite.blank?

    errors.add(:date_debut_etablissement_principal, 'Date debut activité non renseigné')
  end

  def etabs_pri
    @etabs_pri ||= etabs_with_type_etablissement('PRI') + etabs_with_type_etablissement('SEP')
  end

  def etabs_with_type_etablissement(type_etab)
    Etablissement
      .where(type_etablissement: type_etab, siren: siren)
      .select { |e| e.dossier_entreprise.date_radiation.blank? }
  end

  def inscription_secondaire?
    !inscription_principale?
  end

  def inscription_principale?
    type_inscription == 'P'
  end

  def en_activite?
    !date_radiation.nil?
  end

  # this will not warn about multiple SIE/SEP on this dossier / siren
  def siege_social
    @siege_social ||= etablissements.find_by(type_etablissement: 'SIE') || etablissements.find_by(type_etablissement: 'SEP')
  end

  # this will not warn about multiple PRI/SEP on this dossier / siren
  def etablissement_principal
    @etablissement_principal ||= etablissements.find_by(type_etablissement: 'PRI') || etablissements.find_by(type_etablissement: 'SEP')
  end

  def type_greffe
    codes_greffes_tribunal_instance.include?(code_greffe) ? :tribunal_instance : :tribunal_commerce
  end

  private

  def codes_greffes_tribunal_instance
    YAML.load_file('config/codes_greffes_tribunal_instance.yml')
      .map(&:keys)
      .flatten
  end
end
