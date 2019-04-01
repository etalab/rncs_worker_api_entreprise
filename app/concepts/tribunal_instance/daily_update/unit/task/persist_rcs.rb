module TribunalInstance
  module DailyUpdate
    module Unit
      module Task
        class PersistRcs < Trailblazer::Operation
          step ->(ctx, dossier:, **) { !dossier.siren.nil? }
            fail :log_siren_key_missing, fail_fast: true
          step ->(ctx, dossier:, **) { !dossier.numero_gestion.nil? }
            fail :log_numero_gestion_key_missing, fail_fast: true

          step :find_existing_dossier, Output(:failure) => Track(:no_dossier_found)
          pass :log_deleting_existing_dossier
          step ->(ctx, existing_dossier:, **) { existing_dossier.destroy }

          pass :log_no_dossier_found, magnetic_to: [:no_dossier_found]
          step ->(ctx, dossier:, **) { dossier.save }
          pass :log_dossier_persisted

          def find_existing_dossier(ctx, dossier:, **)
            ctx[:existing_dossier] = DossierEntreprise.find_by(
              code_greffe: dossier.code_greffe,
              numero_gestion: dossier.numero_gestion,
              siren: dossier.siren
            )
          end

          def log_dossier_persisted(ctx, dossier:, logger:, **)
            logger.info "Dossier persisted id: #{dossier.id} (siren: #{dossier.siren}, numéro gestion: #{dossier.numero_gestion}, code greffe: #{dossier.code_greffe}"
          end

          def log_no_dossier_found(ctx, logger:, **)
            logger.info 'No dossier found, creating it...'
          end

          def log_deleting_existing_dossier(ctx, logger:, **)
            logger.info "Existing dossier found, deleting it..."
          end

          def log_siren_key_missing(ctx, dossier:, logger:, **)
            logger.error "Siren is missing for this dossier numéro gestion: #{dossier.numero_gestion}"
          end

          def log_numero_gestion_key_missing(ctx, dossier:, logger:, **)
            logger.error "Numéro gestion is missing for this dossier siren: #{dossier.siren}"
          end
        end
      end
    end
  end
end
