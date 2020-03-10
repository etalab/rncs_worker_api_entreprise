class PersonnePhysique < ApplicationRecord
  belongs_to :dossier_entreprise

  FRENCH_DATE_FORMAT = /\d{2}(-|\/)\d{2}(-|\/)\d{4}/
  US_DATE_FORMAT = /\d{4}(-|\/)\d{2}(-|\/)\d{2}/
  DATE_FORMAT = /(#{FRENCH_DATE_FORMAT}|#{US_DATE_FORMAT})/

  validates :nom_patronyme, presence: true
  validates :prenoms, presence: true
  validates :date_naissance, format: { with: DATE_FORMAT }
  validates :ville_naissance, presence: true
  validates :nationalite, presence: true
  validate :adresse_domicile_valide

  def adresse_domicile_valide
    return if (adresse_ligne_1 || adresse_ligne_2) &&
      adresse_code_postal

    errors.add(:adresse_domicile, 'Adresse incomplète ligne 1, 2 ou code postal manquant')
  end
end
