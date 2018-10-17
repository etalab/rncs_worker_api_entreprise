Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    get 'infos_identite_entreprise_rncs/:siren' => '/api/infos_identite_entreprise_rncs#show'
  end
end
