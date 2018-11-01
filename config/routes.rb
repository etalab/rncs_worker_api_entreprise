Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # TODO To be refactor (coming soon)
  namespace :api do
    get 'pdf/:siren' => '/api/pdf#show'
  end

  get 'infos_identite_entreprise/:siren', to: 'api/infos_identite_entreprise#show'
end
