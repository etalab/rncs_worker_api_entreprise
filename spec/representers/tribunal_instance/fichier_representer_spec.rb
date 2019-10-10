require 'rails_helper'

describe TribunalInstance::FichierRepresenter, :representer do
  subject { fichier_representer }

  it { is_expected.to be_a(RepresenterHelper::RSpec::Fichier) }

  its(:greffes) { is_expected.to have_attributes(count: 2) }
  its(:greffes) { are_expected.to all(respond_to(:dossiers_entreprises)) }
  its(:greffes) { are_expected.to all(respond_to(:entreprises)) }
  its(:greffes) { are_expected.to all(respond_to(:code_greffe)) }

  it 'has code greffe 9712 and 0000' do
    expect(subject.greffes).to contain_exactly(
      an_object_having_attributes(code_greffe: '9712'),
      an_object_having_attributes(code_greffe: '0000')
    )
  end
end
