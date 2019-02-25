class DossierEntreprise < ApplicationRecord
  include ClearDataHelper

  has_one :personne_morale, dependent: :destroy
  has_one :personne_physique, dependent: :destroy
  has_many :representants, dependent: :destroy
  has_many :etablissements, dependent: :destroy
  has_many :observations, dependent: :destroy

  has_one :titmc_entreprise,
    dependent: :destroy,
    class_name: 'TribunalInstance::Entreprise'

  has_one :titmc_entreprise,
    dependent: :destroy,
    class_name: 'TribunalInstance::Entreprise'

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
