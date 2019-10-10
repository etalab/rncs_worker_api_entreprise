module RepresenterHelper
  module RSpec
    Fichier = Struct.new(:greffes)

    def fichier_representer
      xml_path = Rails.root.join('spec', 'fixtures', 'titmc', 'xml', '9712_S1_20180505_lot02.xml')

      TribunalInstance::FichierRepresenter
        .new(Fichier.new)
        .from_xml(File.read(xml_path.to_s))
    end

    def main_greffe
      fichier_representer
        .greffes
        .find { |g| g.code_greffe == '9712' }
    end

    def greffe_0000
      fichier_representer
        .greffes
        .find { |g| g.code_greffe == '0000' }
    end

    def dossier_entreprise_pm_representer
      main_greffe
        .dossiers_entreprises
        .first
    end

    def entreprise_pm_representer
      main_greffe
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
      main_greffe
        .entreprises[1]
    end

    def entreprise_greffe_0000
      greffe_0000
        .entreprises
        .first
    end
  end
end
