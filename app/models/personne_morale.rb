class PersonneMorale < ApplicationRecord
  belongs_to :dossier_entreprise

  validates :denomination, presence: true
  validates :forme_juridique, presence: true
  validates :activite_principale, presence: true
  validates :capital, numericality: true
  validates :devise, presence: true
  validates :date_cloture, presence: true, format: { with: /\d{2}\s.+/ }
  validates :duree_pm, numericality: true
  validate :un_seul_siege_ouvert,
           :adresse_siege_valide

  def un_seul_siege_ouvert
    return if sieges.count == 1

    errors.add(:adresse_siege, "#{sieges.count} siège(s) trouvé(s)")
  end

  def adresse_siege_valide
    siege = sieges.first
    return if siege.nil?
    return if (siege.adresse_ligne_1 || siege.adresse_ligne_2) &&
      siege.adresse_code_postal

    errors.add(:adresse_siege, 'Adresse incomplète ligne 1, 2 ou code postal manquant')
  end

  private

  def sieges
    @sieges ||= dossier_entreprise.etablissements.where(type_etablissement: 'SIE') + dossier_entreprise.etablissements.where(type_etablissement: 'SEP')
  end
end
