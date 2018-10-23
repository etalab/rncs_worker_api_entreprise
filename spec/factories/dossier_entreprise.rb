FactoryBot.define do
  factory :dossier_entreprise do
    code_greffe { '1234' }
    nom_greffe { 'Somewhere in spacetime' }
    numero_gestion { '1968A00666' }
    siren { '000000000' }
    type_inscription { 'P' }
    date_immatriculation { '1968-05-02' }
    date_derniere_modification { '2018-01-01' }
    libelle_derniere_modification { 'Création' }

    factory :auto_entrepreneur do
      siren { '123456789' }
      nom_greffe { 'Greffe AE' }

      after :create do |dossier|
        create :siege_social, dossier_entreprise: dossier
        create :personne_physique, dossier_entreprise: dossier
        create :president_pp, dossier_entreprise: dossier
      end
    end

    factory :entreprise_simple do
      siren { '111111111' }
      nom_greffe { 'Greffe entreprise simple' }

      after :create do |dossier|
        create :siege_social, dossier_entreprise: dossier
        create :personne_morale, dossier_entreprise: dossier
        create :president_pm, dossier_entreprise: dossier
      end
    end

    factory :entreprise_complexe do
      siren { '222222222' }
      nom_greffe { 'Greffe entreprise complexe' }

      after :create do |dossier|
        create :siege_social, dossier_entreprise: dossier
        create_list :etablissement, 5, dossier_entreprise: dossier
        create :personne_morale, dossier_entreprise: dossier
        create :president_pm, dossier_entreprise: dossier
        create_list :representant_pm, 3, dossier_entreprise: dossier
        create_list :representant_pp, 3, dossier_entreprise: dossier
      end
    end

    factory :entreprise_without_siege_social do
      after :create do |dossier|
        create_list :etablissement, 4, dossier_entreprise: dossier
      end
    end
  end
end