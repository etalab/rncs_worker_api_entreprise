require 'rails_helper'

describe SectionObservations do
  class DummyPdfObs
    # it removes an UTF-8 warning in specs (handled in identite_entreprise.rb with UTF-8 font)
    Prawn::Font::AFM.hide_m17n_warning = true
    include SectionObservations
  end

  subject { PDF::Inspector::Text.analyze(pdf.render).strings }
  let(:pdf) { DummyPdfObs.new }

  it 'works' do
    params = { observations: [
      attributes_for(:observation, date_ajout: '2010-01-04'),
      attributes_for(:observation, date_ajout: '2018-04-31'),
      attributes_for(:observation, date_ajout: '2010-02-04')]
    }
    pdf.section_observations params

    data = [
      'Observations',
      'Mention n°4000A du 2018-04-31',
      'I can see you',
      'Mention n°4000A du 2010-02-04',
      'I can see you',
      'Mention n°4000A du 2010-01-04',
      'I can see you',
    ]

    expect(subject).to eq data
  end

  it 'handle null date_ajout at the end' do
    params = { observations: [
      attributes_for(:observation, date_ajout: nil),
      attributes_for(:observation, date_ajout: '2018-07-05'),
      attributes_for(:observation, date_ajout: '2018-02-15')]
    }
    pdf.section_observations params

    last_obs = subject[5]
    expect(last_obs).to eq 'Mention n°4000A du'
  end
end
