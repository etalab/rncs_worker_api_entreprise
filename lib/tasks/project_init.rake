require 'fileutils'

namespace :project_init do
  desc 'create rncs_sources config file'
  task :config do
    puts 'create rncs_sources config file'
    file = File.new('config/rncs_sources.yml', 'w+')
    file.write(rncs_sources.unindent)
  end

  def rncs_sources
  <<-YML
    defaults: &DEFAULTS
      path: '~/rncs_data/IMR_Donnees_Saisies'
      import_batch_size: 5000

    development:
      <<: *DEFAULTS
    test:
      <<: *DEFAULTS
  YML
  end
end
