Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'infos_identite_entreprise/:siren',     to: 'api/infos_identite_entreprise#show'
  get 'infos_identite_entreprise/:siren/pdf', to: 'api/infos_identite_entreprise#pdf'
end
