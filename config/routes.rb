Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'

  concern :v1_routes do
    get 'infos_identite_entreprise/:siren',     to: 'api/v1/infos_identite_entreprise#show'
    get 'infos_identite_entreprise/:siren/pdf', to: 'api/v1/infos_identite_entreprise#pdf'
  end

  scope :v1 do
    concerns :v1_routes
  end
end
