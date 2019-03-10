module TribunalInstance
  module Stock
    module Unit
      module Operation
        class Import < Trailblazer::Operation
          extend ClassDependencies

          BATCH_SIZE         = 5_000
          Fichier            = Struct.new(:greffes)
          self[:fichier]     = Fichier.new
          self[:representer] = ::TribunalInstance::FichierRepresenter.new self[:fichier]

          pass ->(ctx, logger:, **) { logger.info 'Starting import' }

          step :parse_xml
          step :extract_data_from_greffes
          pass :log_mapping_done

          step :create_associations_dossiers_and_entreprises
          step :create_entreprises_hash_with_siren
          step :merge_data_from_code_greffe_0000
            fail :log_missing_siren_in_main_greffe
          pass ->(ctx, logger:, **) { logger.info 'Models associations done' }

          step :persist
          pass ->(ctx, logger:, **) { logger.info 'All data persisted' }


          def parse_xml(ctx, path:, representer:, **)
            representer.from_xml ::File.read path
          end

          def extract_data_from_greffes(ctx, fichier:, code_greffe:, **)
            main_greffe                = fichier.greffes.find { |g| g.code_greffe == code_greffe }
            ctx[:greffe_0000]          = fichier.greffes.find { |g| g.code_greffe == '0000' }
            ctx[:dossiers_entreprises] = main_greffe.dossiers_entreprises
            ctx[:entreprises]          = main_greffe.entreprises
          end

          def log_mapping_done(ctx, logger:, dossiers_entreprises:, **)
            logger.info "Trailblazer mapping done (#{dossiers_entreprises.count} dossiers found)"
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

          def create_entreprises_hash_with_siren(ctx, entreprises:, **)
            hash_entreprises = {}
            # it costs nothing to create & it's instant compared to Array.find
            entreprises.each { |e| hash_entreprises[e.siren] = e }

            ctx[:hash_entreprises] = hash_entreprises
          end

          def merge_data_from_code_greffe_0000(ctx, hash_entreprises:, greffe_0000:, **)
            greffe_0000.entreprises.each do |entreprise_code_greffe_0000|
              entreprise_related = hash_entreprises[entreprise_code_greffe_0000.siren]

              if entreprise_related.nil?
                ctx[:missing_siren] = entreprise_code_greffe_0000.siren
                return false
              end

              operation = MergeGreffeZero.call(
                entreprise_code_greffe_0000: entreprise_code_greffe_0000,
                entreprise_related: entreprise_related,
                code_greffe: ctx[:code_greffe],
                logger: ctx[:logger]
              )

              return false if operation.failure?
            end
          end

          def log_missing_siren_in_main_greffe(ctx, logger:, **)
            if ctx[:missing_siren]
              logger.error "No entreprise found in main greffe section for entreprise #{ctx[:missing_siren]} of greffe 0000"
            end
          end

          def persist(ctx, dossiers_entreprises:, **)
            DossierEntreprise.import dossiers_entreprises,
              recursive: true,
              batch_size: BATCH_SIZE
          end
        end
      end
    end
  end
end
