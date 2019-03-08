module TribunalInstance
  module DailyUpdate
    module Unit
      module Operation
        class Import < Trailblazer::Operation
          pass ->(ctx, logger:, **) { logger.info 'Starting import' }

          step :parse_xml
          step :fetch_type
          step :fetch_code_greffe
            fail :log_too_many_codes_greffes, fail_fast: true
          step :fetch_all_data
          pass :log_trailblazer_mapping_done
          step :create_associations_dossiers_and_entreprises
          step :check_file_type
            fail :log_file_ignored, Output(:success) => 'End.success'
          step :persist
            fail :log_operation_fails

          pass ->(ctx, logger:, **) { logger.info 'All valid data persisted' }

          def parse_xml(ctx, path:, **)
            ctx[:fichier] = TribunalInstance::Fichier.new

            representer   = ::TribunalInstance::FichierRepresenter.new ctx[:fichier]
            representer.from_xml ::File.read path
          end

          def fetch_type(ctx, fichier:, **)
            ctx[:type] = fichier.type
          end

          def fetch_code_greffe(ctx, fichier:, **)
            if fichier.greffes.count == 1
              ctx[:code_greffe] = fichier.greffes.first.code_greffe
            end
          end

          def fetch_all_data(ctx, fichier:, **)
            ctx[:dossiers_entreprises] = fichier.greffes.first.dossiers_entreprises
            ctx[:entreprises]          = fichier.greffes.first.entreprises
          end

          def create_associations_dossiers_and_entreprises(ctx, dossiers_entreprises:, entreprises:, **)
            dossiers_entreprises.each_with_index do |dossier, index|
              # dossiers_entreprises[index] and entreprise[index] refers to the same company
              # they are created in the same time by Trailblazer representer
              # equivalent as : dossier.titmc_entreprise = entreprises.find_by(siren: dossier.siren, numero_gestion: dossier.numero_gestion)
              # but faster
              # so we can do this safely:
              dossier.titmc_entreprise = entreprises[index]
            end
          end

          def check_file_type(ctx, type:, **)
            type == 'RCS'
          end

          def persist(ctx, dossiers_entreprises:, logger:, **)
            dossiers_entreprises.each do |dossier|
              operation = TribunalInstance::DailyUpdate::Unit::Task::PersistRcs
                .call(dossier: dossier, logger: logger)

              return false if operation.failure?
            end
          end

          def log_too_many_codes_greffes(ctx, fichier:, logger:, **)
            logger.error "Too many code greffe found #{fichier.greffes.count} (#{fichier.greffes.map(&:code_greffe).join(', ')})"
          end

          def log_trailblazer_mapping_done(ctx, dossiers_entreprises:, logger:, **)
            logger.info "Trailblazer mapping done #{dossiers_entreprises.count} dossiers found"
          end

          def log_file_ignored(ctx, type:, logger:, **)
            logger.info "Ignoring file (#{type}) : #{ctx[:path]}"
          end

          def log_operation_fails(ctx, logger:, **)
            logger.error "An operation failed"
          end
        end
      end
    end
  end
end
