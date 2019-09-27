namespace :fiches_identite do
  desc 'Ratio of entreprise covered by the fiche identity generation algorithm'
  task compute_ratio: :environment do
    log_level = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = :error
    ratio_op = Entreprise::Operation::CoverRatio.call
    ActiveRecord::Base.logger.level = log_level

    if ratio_op.success?
      @nb_siren_total = 5_812_698
      @nb_siren_sec_immat_only = ratio_op[:sec_immat_only].count
      @nb_siren_scope = @nb_siren_total - @nb_siren_sec_immat_only
      @nb_success = ratio_op[:fiche_success]
      @nb_failure = ratio_op[:fiche_failure]
      @errors_report = ratio_op[:errors]

      create_report_file
    else
      puts 'An error occured while computing ratio'
    end
  end

  def create_report_file
    content = report_content
    file = File.new('fiche_covered_ratio.txt', 'w+')
    file.write(content)
  end

  def report_content
    <<REPORT
Nombre total de siren en base : #{@nb_siren_total}
Nombre de siren dont on a aucune immatriculation principale : #{@nb_siren_sec_immat_only}
Nombre de siren du périmètre #{@nb_siren_scope}

Nombre d'échecs à la génération de la fiche d'identité : #{@nb_failure} soit un ratio de #{@nb_failure * 100 / @nb_siren_scope}

Détails des erreurs :
- #{@errors_report['1'][:error_message]} : #{@errors_report['1'][:nb]} erreurs
- #{@errors_report['2'][:error_message]} : #{@errors_report['2'][:nb]} erreurs
REPORT
  end
end
