module TribunalCommerce
  module Operation
    class DailyImport < Trailblazer::Operation
      extend ClassDependencies

      self[:logger] = Rails.logger

      step :log_import_starts
      step :fetch_new_daily_updates
      fail :log_no_updates, fail_fast: true
      step :import_updates
      fail :log_import_fail, fail_fast: true

      def fetch_new_daily_updates(_, **)
        new_updates_found = TribunalCommerce::DailyUpdate::Operation::Load.call(delay: 1)
        new_updates_found.success?
      end

      def import_updates(_, **)
        import = TribunalCommerce::DailyUpdate::Operation::Import.call
        import.success?
      end

      def log_no_updates(_, logger:, **)
        logger.error('No updates have been added to the queue, aborting import...')
      end

      def log_import_fail(_, logger:, **)
        logger.error('An error occured during import. Aborting...')
      end

      def log_import_starts(_, logger:, **)
        logger.info('Starting daily import...')
      end
    end
  end
end
