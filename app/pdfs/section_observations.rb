module SectionObservations
  include Prawn::View
  include PdfHelper

  def section_observations(observations:, **)
    @observations = observations

    display_section_title 'Observations'
    sort_observations
    display_observations_in_block
  end

  private

  def sort_observations
    @observations.sort_by! { |o| o[:date_ajout] || '0000-00-00' }
    @observations.reverse!
  end

  def display_observations_in_block
    @observations.each do |obs|
      display_table_block [
        ["Mention n°#{obs[:numero]} du #{obs[:date_ajout]}", ''],
        [obs[:texte], '']
      ]

      move_down 10
    end
  end
end
