require 'rails_helper'

describe TribunalCommerce::Helper::FileImporter, :trb do
  it_behaves_like 'import_line_by_line',
    :supersede_dossiers_entreprise_from_pm,
    DossierEntreprise::Operation::Supersede,
    DOSSIER_ENTREPRISE_FROM_PM_HEADER_MAPPING

  it_behaves_like 'import_line_by_line',
    :supersede_dossiers_entreprise_from_pp,
    DossierEntreprise::Operation::Supersede,
    DOSSIER_ENTREPRISE_FROM_PP_HEADER_MAPPING

  it_behaves_like 'import_line_by_line',
    :import_personnes_morales,
    PersonneMorale::Operation::Create,
    PM_HEADER_MAPPING

  it_behaves_like 'import_line_by_line',
    :import_personnes_physiques,
    PersonnePhysique::Operation::Create,
    PP_HEADER_MAPPING

  it_behaves_like 'import_line_by_line',
    :import_representants,
    Representant::Operation::Create,
    REP_HEADER_MAPPING

  it_behaves_like 'import_line_by_line',
    :import_etablissements,
    Etablissement::Operation::Create,
    ETS_HEADER_MAPPING

  it_behaves_like 'import_line_by_line',
    :import_observations,
    Observation::Operation::UpdateOrCreate,
    OBS_HEADER_MAPPING
end
