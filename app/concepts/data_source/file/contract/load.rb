module DataSource
  module File
    module Contract
      Load = Dry::Validation.Schema do
        configure do
          config.messages_file = Rails.root.join('config/dry_validation_errors.yml').to_s

          def file?(file_path)
            ::File.file?(file_path)
          end
        end

        required(:file_path).filled(:file?)
      end
    end
  end
end
