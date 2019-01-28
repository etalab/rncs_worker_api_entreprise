module RepresenterHelper
  module RSpec
    Fichier = Struct.new(:greffes)

    def fichier_representer
      xml_path = Rails.root.join 'spec', 'fixtures', 'titmc', 'xml', '9712_S1_20180505_lot02.xml'

    TribunalInstance::FichierRepresenter
        .new(Fichier.new)
        .from_xml(File.read(xml_path.to_s))
    end

    def greffe_principal
      fichier_representer
        .greffes
        .find { |g| g.code_greffe == '9712' }
    end

    def dossier_entreprise_pm_representer
      greffe_principal
        .dossiers_entreprises
        .first
    end

    def entreprise_pm_representer
      greffe_principal
        .entreprises
        .first
    end

    def adresse_domiciliataire_representer
      entreprise_pm_representer
        .adresse_domiciliataire
    end

    def etablissement_representer
      entreprise_pm_representer
        .etablissements
        .first
    end

    def entreprise_pp_representer
      greffe_principal
        .entreprises[1]
    end
  end
end
