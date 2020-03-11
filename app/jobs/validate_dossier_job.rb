class ValidateDossierJob < ApplicationJob
  queue_as :analysis

  DOSSIER_ENTREPRISE_HEADERS = %i[code_greffe numero_gestion siren checksum nom_greffe date_immatriculation type_inscription etablissement_principal]
  PM_HEADERS = %i[pm_denomination pm_forme_juridique pm_activite_principale pm_capital pm_devise pm_adresse_siege pm_date_cloture pm_duree_pm]
  PP_HEADERS = %i[pp_nom_patronyme pp_prenoms pp_date_naissance pp_ville_naissance pp_nationalite pp_adresse_domicile]
  HEADERS = DOSSIER_ENTREPRISE_HEADERS + PM_HEADERS + PP_HEADERS

  def perform(code_greffe, ids)
    @code_greffe = code_greffe
    @errors = []

    ids.each do |id|
      @current_dossier = DossierEntreprise.find id
      add_error unless @current_dossier.valid?
    end

    append_errors_to_csv
  end

  def add_error
    @errors << format_error
  end

  def append_errors_to_csv
    CSV.open(self.class.filename(@code_greffe), 'a') do |csv|
      @errors.each do |errors_hash|
        csv << errors_hash.values
      end
    end
  end

  def format_error
    errors_hash = {}

    HEADERS.each { |k| errors_hash[k] = '' }

    @current_dossier.errors.messages.each { |k, v| errors_hash[k] = v.join(', ') }

    errors_hash.delete(:personne_morale)
    errors_hash.delete(:personne_physique)

    if personne_morale_has_errors?
      @current_dossier.personne_morale.errors.messages.each { |k, v| errors_hash["pm_#{k}".to_sym] = v.join(', ') }
    elsif personne_physique_has_errors?
      @current_dossier.personne_physique.errors.messages.each { |k, v| errors_hash["pp_#{k}".to_sym] = v.join(', ') }
    end

    errors_hash[:code_greffe] = @current_dossier.code_greffe
    errors_hash[:numero_gestion] = @current_dossier.numero_gestion
    errors_hash[:siren] = @current_dossier.siren

    errors_hash
  end

  def personne_physique_has_errors?
    @current_dossier.personne_physique && @current_dossier.personne_physique.errors
  end

  def personne_morale_has_errors?
    @current_dossier.personne_morale && @current_dossier.personne_morale.errors
  end

  def self.filename(code_greffe)
    "./tmp/reports/report_for_#{code_greffe}.csv"
  end
end
