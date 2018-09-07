module DataSource
  module Stock
    module TribunalCommerce
      module Unit
        module Operation
          class ResetDatabase
            class << self
              def call(ctx, code_greffe:, **)
                # Going my own way because of ActiveRecord :dependent option's performance
                # Be careful to drop rows related to the corresponding greffe only

                code_greffe = code_greffe.to_i.to_s

                # Identite and Adresse models have polymorphic associations
                [
                  ['representants',       'Representant'],
                  ['personnes_physiques', 'PersonnePhysique']
                ]
                  .each do |table, type|
                  identites = Identite
                    .joins("INNER JOIN #{table} ON identites.identifiable_id = #{table}.id
                            INNER JOIN entreprises ON #{table}.entreprise_id = entreprises.id"
                          )
                    .where(identifiable_type: type)
                    .where(entreprises: { code_greffe: code_greffe })
                    .unscope(:order)

                  identites.delete_all unless identites.empty?
                end

                [
                  ['representants', 'Representant'],
                  ['etablissements', 'Etablissement'],
                  ['personnes_physiques', 'PersonnePhysique'],
                ]
                  .each do |table, type|
                  adresses = Adresse
                    .joins("INNER JOIN #{table} ON adresses.addressable_id = #{table}.id
                            INNER JOIN entreprises ON #{table}.entreprise_id = entreprises.id"
                          )
                    .where(addressable_type: type)
                    .where(entreprises: { code_greffe: code_greffe })
                    .unscope(:order)

                  adresses.delete_all unless adresses.empty?
                end

                Observation
                  .joins(:entreprise)
                  .where(entreprises: { code_greffe: code_greffe })
                  .unscope(:order)
                  .delete_all

                Representant
                  .joins(:entreprise)
                  .where(entreprises: { code_greffe: code_greffe })
                  .unscope(:order)
                  .delete_all

                Etablissement
                  .joins(:entreprise)
                  .where(entreprises: { code_greffe: code_greffe })
                  .unscope(:order)
                  .delete_all

                PersonneMorale
                  .joins(:entreprise)
                  .where(entreprises: { code_greffe: code_greffe })
                  .unscope(:order)
                  .delete_all

                PersonnePhysique
                  .joins(:entreprise)
                  .where(entreprises: { code_greffe: code_greffe })
                  .unscope(:order)
                  .delete_all

                Entreprise
                  .where(code_greffe: code_greffe)
                  .unscope(:order)
                  .delete_all

                true
                # TODO wrap into a transaction and deal with ActiveRecord errors
              end
            end
          end
        end
      end
    end
  end
end
